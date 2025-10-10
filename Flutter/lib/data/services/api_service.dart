import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/user.dart';
import '../models/book.dart';
import '../models/transaction.dart';
import '../models/locker.dart';

/// Spring Boot API 서비스 클래스
/// 비즈니스 로직, 거래 처리, CRUD 작업 담당
class ApiService {
  late final Dio _dio;
  static const String baseUrl = 'http://localhost:8080/api'; // 개발 환경 URL

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 인터셉터 추가 (로그, 인증 토큰 등)
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => debugPrint('[API] $obj'),
    ));

    // 인증 토큰 인터셉터
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Supabase JWT 토큰 추가
        // final token = SupabaseService.client.auth.currentSession?.accessToken;
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('[API Error] ${error.message}');
        handler.next(error);
      },
    ));
  }

  /// === 사용자 관련 API ===

  /// 사용자 생성
  Future<User> createUser(User user) async {
    try {
      final response = await _dio.post('/users', data: user.toJson());
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '사용자 생성');
    }
  }

  /// 사용자 정보 가져오기
  Future<User> getUser(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '사용자 정보 조회');
    }
  }

  /// 사용자 정보 업데이트
  Future<User> updateUser(User user) async {
    try {
      final response = await _dio.put('/users/${user.id}', data: user.toJson());
      return User.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '사용자 정보 업데이트');
    }
  }

  /// === 책 관련 API ===

  /// 전체 책 목록 가져오기
  Future<List<Book>> getBooks({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get('/books', queryParameters: {
        'page': page,
        'size': size,
      });
      final List<dynamic> data = response.data['content'] ?? response.data;
      return data.map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e, '책 목록 조회');
    }
  }

  /// 책 검색
  Future<List<Book>> searchBooks({
    required String query,
    BookCondition? condition,
    int? minPrice,
    int? maxPrice,
    String? category,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'q': query,
        'page': page,
        'size': size,
      };

      if (condition != null) queryParams['condition'] = condition.name;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (category != null) queryParams['category'] = category;

      final response = await _dio.get('/books/search', queryParameters: queryParams);
      final List<dynamic> data = response.data['content'] ?? response.data;
      return data.map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e, '책 검색');
    }
  }

  /// 추천 도서 가져오기
  Future<List<Book>> getRecommendedBooks(String userId) async {
    try {
      final response = await _dio.get('/books/recommendations/$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e, '추천 도서 조회');
    }
  }

  /// 내가 등록한 책 목록
  Future<List<Book>> getMyBooks(String userId) async {
    try {
      final response = await _dio.get('/books/my/$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => Book.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e, '내 책 목록 조회');
    }
  }

  /// 특정 책 정보 가져오기
  Future<Book> getBook(String bookId) async {
    try {
      final response = await _dio.get('/books/$bookId');
      return Book.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '책 정보 조회');
    }
  }

  /// 책 등록
  Future<Book> createBook(Book book) async {
    try {
      final response = await _dio.post('/books', data: book.toJson());
      return Book.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '책 등록');
    }
  }

  /// 책 정보 업데이트
  Future<Book> updateBook(Book book) async {
    try {
      final response = await _dio.put('/books/${book.id}', data: book.toJson());
      return Book.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '책 정보 업데이트');
    }
  }

  /// 책 삭제
  Future<void> deleteBook(String bookId) async {
    try {
      await _dio.delete('/books/$bookId');
    } catch (e) {
      throw _handleError(e, '책 삭제');
    }
  }

  /// 책 상태 업데이트
  Future<void> updateBookStatus(String bookId, BookStatus status) async {
    try {
      await _dio.put('/books/$bookId/status', data: {'status': status.name});
    } catch (e) {
      throw _handleError(e, '책 상태 업데이트');
    }
  }

  /// ISBN으로 책 정보 검색
  Future<Book?> searchBookByISBN(String isbn) async {
    try {
      final response = await _dio.get('/books/isbn/$isbn');
      return Book.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      throw _handleError(e, 'ISBN 검색');
    }
  }

  /// === 거래 관련 API ===

  /// 전체 거래 목록
  Future<List<Transaction>> getTransactions({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get('/transactions', queryParameters: {
        'page': page,
        'size': size,
      });
      final List<dynamic> data = response.data['content'] ?? response.data;
      return data.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e, '거래 목록 조회');
    }
  }

  /// 내 대여 거래 (내가 빌려준 것들)
  Future<List<Transaction>> getLendingTransactions(String userId) async {
    try {
      final response = await _dio.get('/transactions/lending/$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e, '대여 거래 조회');
    }
  }

  /// 내 차용 거래 (내가 빌린 것들)
  Future<List<Transaction>> getBorrowingTransactions(String userId) async {
    try {
      final response = await _dio.get('/transactions/borrowing/$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e, '차용 거래 조회');
    }
  }

  /// 진행 중인 거래
  Future<List<Transaction>> getActiveTransactions(String userId) async {
    try {
      final response = await _dio.get('/transactions/active/$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e, '진행 중인 거래 조회');
    }
  }

  /// 특정 거래 정보
  Future<Transaction> getTransaction(String transactionId) async {
    try {
      final response = await _dio.get('/transactions/$transactionId');
      return Transaction.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '거래 정보 조회');
    }
  }

  /// 거래 생성
  Future<Transaction> createTransaction({
    required String bookId,
    required String borrowerId,
    required int rentalDays,
    String? notes,
  }) async {
    try {
      final response = await _dio.post('/transactions', data: {
        'book_id': bookId,
        'borrower_id': borrowerId,
        'rental_days': rentalDays,
        'notes': notes,
      });
      return Transaction.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '거래 생성');
    }
  }

  /// 거래 승인
  Future<Transaction> approveTransaction(String transactionId) async {
    try {
      final response = await _dio.put('/transactions/$transactionId/approve');
      return Transaction.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '거래 승인');
    }
  }

  /// 거래 거절
  Future<Transaction> rejectTransaction(String transactionId, String reason) async {
    try {
      final response = await _dio.put('/transactions/$transactionId/reject', data: {
        'reason': reason,
      });
      return Transaction.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '거래 거절');
    }
  }

  /// 거래 완료
  Future<Transaction> completeTransaction(String transactionId) async {
    try {
      final response = await _dio.put('/transactions/$transactionId/complete');
      return Transaction.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '거래 완료');
    }
  }

  /// 거래 취소
  Future<Transaction> cancelTransaction(String transactionId) async {
    try {
      final response = await _dio.put('/transactions/$transactionId/cancel');
      return Transaction.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '거래 취소');
    }
  }

  /// 사물함 배정
  Future<Transaction> assignLocker(String transactionId, int lockerId) async {
    try {
      final response = await _dio.put('/transactions/$transactionId/assign-locker', data: {
        'locker_id': lockerId,
      });
      return Transaction.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '사물함 배정');
    }
  }

  /// === 사물함 관련 API ===

  /// 전체 사물함 목록
  Future<List<Locker>> getLockers() async {
    try {
      final response = await _dio.get('/lockers');
      final List<dynamic> data = response.data;
      return data.map((json) => Locker.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e, '사물함 목록 조회');
    }
  }

  /// 사용 가능한 사물함 목록
  Future<List<Locker>> getAvailableLockers() async {
    try {
      final response = await _dio.get('/lockers/available');
      final List<dynamic> data = response.data;
      return data.map((json) => Locker.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e, '사용 가능한 사물함 조회');
    }
  }

  /// 특정 사물함 정보
  Future<Locker> getLocker(int lockerId) async {
    try {
      final response = await _dio.get('/lockers/$lockerId');
      return Locker.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '사물함 정보 조회');
    }
  }

  /// 사물함 예약
  Future<Locker> reserveLocker(int lockerId, String transactionId) async {
    try {
      final response = await _dio.post('/lockers/$lockerId/reserve', data: {
        'transaction_id': transactionId,
      });
      return Locker.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '사물함 예약');
    }
  }

  /// 사물함 반납
  Future<Locker> releaseLocker(int lockerId) async {
    try {
      final response = await _dio.post('/lockers/$lockerId/release');
      return Locker.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '사물함 반납');
    }
  }

  /// 사물함 열기
  Future<bool> openLocker(int lockerId, String accessCode) async {
    try {
      final response = await _dio.post('/lockers/$lockerId/open', data: {
        'access_code': accessCode,
      });
      return response.data['success'] ?? false;
    } catch (e) {
      throw _handleError(e, '사물함 열기');
    }
  }

  /// 사물함 상태 업데이트
  Future<Locker> updateLockerStatus(int lockerId, LockerStatus status) async {
    try {
      final response = await _dio.put('/lockers/$lockerId/status', data: {
        'status': status.name,
      });
      return Locker.fromJson(response.data);
    } catch (e) {
      throw _handleError(e, '사물함 상태 업데이트');
    }
  }

  /// 사물함 접근 코드 생성
  Future<String> generateLockerAccessCode(int lockerId, String transactionId) async {
    try {
      final response = await _dio.post('/lockers/$lockerId/generate-code', data: {
        'transaction_id': transactionId,
      });
      return response.data['access_code'];
    } catch (e) {
      throw _handleError(e, '접근 코드 생성');
    }
  }

  /// === 포인트 관련 API ===

  /// 포인트 내역 조회
  Future<List<Map<String, dynamic>>> getPointHistory(String userId) async {
    try {
      final response = await _dio.get('/users/$userId/point-history');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw _handleError(e, '포인트 내역 조회');
    }
  }

  /// 포인트 충전
  Future<void> chargePoints(String userId, int amount) async {
    try {
      await _dio.post('/users/$userId/charge-points', data: {
        'amount': amount,
      });
    } catch (e) {
      throw _handleError(e, '포인트 충전');
    }
  }

  /// === 에러 처리 ===

  Exception _handleError(dynamic error, String operation) {
    if (error is DioException) {
      final message = error.response?.data?['message'] ?? error.message;
      return Exception('$operation 실패: $message');
    }
    return Exception('$operation 중 알 수 없는 오류가 발생했습니다: ${error.toString()}');
  }
}