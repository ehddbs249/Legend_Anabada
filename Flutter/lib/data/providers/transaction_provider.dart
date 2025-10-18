import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';

/// 거래 관련 상태 관리 Provider
class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> _myLendingTransactions = [];
  List<Transaction> _myBorrowingTransactions = [];
  List<Transaction> _activeTransactions = [];

  bool _isLoading = false;
  String? _errorMessage;

  /// Getter 들
  List<Transaction> get transactions => _transactions;
  List<Transaction> get myLendingTransactions => _myLendingTransactions;
  List<Transaction> get myBorrowingTransactions => _myBorrowingTransactions;
  List<Transaction> get activeTransactions => _activeTransactions;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 전체 거래 내역 가져오기
  Future<void> fetchTransactions() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('book_transaction')
          .select()
          .order('trans_date', ascending: false);

      _transactions = (response as List).map((json) => Transaction.fromJson(json)).toList();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('거래 내역을 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 내 대여 거래 가져오기 (내가 빌려준 것들)
  Future<void> fetchMyLendingTransactions(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('book_transaction')
          .select('''
            *,
            book(point_price, title, img_url),
            user:user_id(name),
            borrower:borrower_id(name)
          ''')
          .eq('user_id', userId)
          .order('trans_date', ascending: false);

      _myLendingTransactions = (response as List).map((json) => Transaction.fromJson(json)).toList();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('대여 내역을 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 내 차용 거래 가져오기 (내가 빌린 것들)
  Future<void> fetchMyBorrowingTransactions(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('book_transaction')
          .select('''
            *,
            book(point_price, title, img_url),
            user:user_id(name),
            borrower:borrower_id(name)
          ''')
          .eq('borrower_id', userId)
          .order('trans_date', ascending: false);

      _myBorrowingTransactions = (response as List).map((json) => Transaction.fromJson(json)).toList();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('차용 내역을 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 진행 중인 거래 가져오기
  Future<void> fetchActiveTransactions(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('book_transaction')
          .select('''
            *,
            book(point_price, title, img_url),
            user:user_id(name),
            borrower:borrower_id(name)
          ''')
          .or('user_id.eq.$userId,borrower_id.eq.$userId')
          .inFilter('trans_status', ['pending', 'active'])
          .order('trans_date', ascending: false);

      _activeTransactions = (response as List).map((json) => Transaction.fromJson(json)).toList();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('진행 중인 거래를 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 거래 생성 (책 대여 요청) - PostgreSQL 함수 호출
  Future<Map<String, dynamic>> createTransaction({
    required String bookId,
    required String borrowerId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // PostgreSQL 함수 호출
      final response = await Supabase.instance.client
          .rpc('create_book_transaction', params: {
            'p_book_id': bookId,
            'p_borrower_id': borrowerId,
          });

      _setLoading(false);

      if (response['success'] == true) {
        // 성공 시 거래 목록 갱신
        await fetchActiveTransactions(borrowerId);
        notifyListeners();

        return {
          'success': true,
          'message': response['message'],
          'trans_id': response['trans_id'],
          'point_spent': response['point_spent'],
        };
      } else {
        // 실패 시 에러 메시지 설정
        _setError(response['message']);
        return {
          'success': false,
          'message': response['message'],
          'required': response['required'],
          'current': response['current'],
        };
      }
    } catch (e) {
      _setError('거래 생성 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return {
        'success': false,
        'message': '거래 생성 중 오류가 발생했습니다: ${e.toString()}',
      };
    }
  }

  /// 거래 완료 (책 반납)
  Future<bool> completeTransaction(String transactionId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('book_transaction')
          .update({'trans_status': 'completed'})
          .eq('trans_id', transactionId)
          .select()
          .single();

      final transaction = Transaction.fromJson(response);
      _updateTransactionInLists(transaction);
      _activeTransactions.removeWhere((t) => t.id == transactionId);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('거래 완료 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 거래 취소
  Future<bool> cancelTransaction(String transactionId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('book_transaction')
          .update({'trans_status': 'cancelled'})
          .eq('trans_id', transactionId)
          .select()
          .single();

      final transaction = Transaction.fromJson(response);
      _updateTransactionInLists(transaction);
      _activeTransactions.removeWhere((t) => t.id == transactionId);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('거래 취소 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 특정 거래 가져오기
  Future<Transaction?> getTransaction(String transactionId) async {
    try {
      final response = await Supabase.instance.client
          .from('book_transaction')
          .select()
          .eq('trans_id', transactionId)
          .single();
      return Transaction.fromJson(response);
    } catch (e) {
      _setError('거래 정보를 불러오는데 실패했습니다: ${e.toString()}');
      return null;
    }
  }

  /// 거래 승인 (미구현 - Supabase 테이블 스키마에 따라 구현 필요)
  Future<bool> approveTransaction(String transactionId) async {
    // TODO: Supabase 테이블 스키마에 승인 필드 추가 필요
    return completeTransaction(transactionId);
  }

  /// 거래 거절 (미구현)
  Future<bool> rejectTransaction(String transactionId, String reason) async {
    return cancelTransaction(transactionId);
  }

  /// 사물함 배정 (미구현)
  Future<bool> assignLocker(String transactionId, String lockerId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('book_transaction')
          .update({'locker_id': lockerId})
          .eq('trans_id', transactionId)
          .select()
          .single();

      final transaction = Transaction.fromJson(response);
      _updateTransactionInLists(transaction);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('사물함 배정 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 연체된 거래 목록 가져오기
  List<Transaction> getOverdueTransactions() {
    return _activeTransactions.where((transaction) {
      return transaction.transStatus == 'overdue';
    }).toList();
  }

  /// 곧 만료되는 거래 목록 가져오기
  List<Transaction> getExpiringTransactions() {
    return _activeTransactions.where((transaction) {
      return transaction.transStatus == 'active';
    }).toList();
  }

  /// 거래 통계 계산
  Map<String, int> getTransactionStats(String userId) {
    final lending = _myLendingTransactions.length;
    final borrowing = _myBorrowingTransactions.length;
    final completed = _transactions
        .where((t) => (t.userId == userId || t.borrowerId == userId) &&
                     t.transStatus == 'completed')
        .length;
    final active = _activeTransactions
        .where((t) => t.userId == userId || t.borrowerId == userId)
        .length;

    return {
      'lending': lending,
      'borrowing': borrowing,
      'completed': completed,
      'active': active,
    };
  }

  /// 포인트 내역 가져오기 (미구현 - UserPointBalance 테이블 구현 필요)
  Future<List<Map<String, dynamic>>> getPointHistory(String userId) async {
    try {
      // TODO: UserPointBalance 테이블 구현
      return [];
    } catch (e) {
      _setError('포인트 내역을 불러오는데 실패했습니다: ${e.toString()}');
      return [];
    }
  }

  /// 모든 목록에서 거래 업데이트
  void _updateTransactionInLists(Transaction updatedTransaction) {
    _updateTransactionInList(_transactions, updatedTransaction);
    _updateTransactionInList(_myLendingTransactions, updatedTransaction);
    _updateTransactionInList(_myBorrowingTransactions, updatedTransaction);
    _updateTransactionInList(_activeTransactions, updatedTransaction);
  }

  /// 특정 목록에서 거래 업데이트
  void _updateTransactionInList(List<Transaction> list, Transaction updatedTransaction) {
    final index = list.indexWhere((transaction) => transaction.id == updatedTransaction.id);
    if (index != -1) {
      list[index] = updatedTransaction;
    }
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 에러 설정
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// 에러 지우기
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// 에러 지우기 (외부에서 호출 가능)
  void clearError() {
    _clearError();
  }
}
