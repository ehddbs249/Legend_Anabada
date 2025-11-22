import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/book.dart';
import '../services/supabase_service.dart';

/// 책 관련 상태 관리 Provider
class BookProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  List<Book> _books = [];
  List<Book> _searchResults = [];
  List<Book> _myBooks = [];
  List<Book> _recommendedBooks = [];

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;

  // 검색 필터
  String _searchQuery = '';
  String?
  _selectedCondition; // condition grade: "excellent", "good", "fair", "poor"
  int? _minPrice;
  int? _maxPrice;
  String? _selectedCategory;

  /// Getter 들
  List<Book> get books => _books;
  List<Book> get searchResults => _searchResults;
  List<Book> get myBooks => _myBooks;
  List<Book> get recommendedBooks => _recommendedBooks;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String? get selectedCondition => _selectedCondition;
  int? get minPrice => _minPrice;
  int? get maxPrice => _maxPrice;
  String? get selectedCategory => _selectedCategory;

  /// 전체 책 목록 가져오기
  Future<void> fetchBooks() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('book')
          .select()
          .order('registered_at', ascending: false);

      _books = (response as List).map((json) => Book.fromJson(json)).toList();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('책 목록을 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 책 검색
  Future<void> searchBooks(String query) async {
    try {
      _setSearching(true);
      _clearError();
      _searchQuery = query;

      if (query.isEmpty) {
        _searchResults = [];
      } else {
        var queryBuilder = Supabase.instance.client
            .from('book')
            .select()
            .eq('book_status', 'available') // 판매 가능한 책만 검색
            .or(
              'title.ilike.%$query%,author.ilike.%$query%,publisher.ilike.%$query%',
            );

        if (_selectedCondition != null) {
          queryBuilder = queryBuilder.eq(
            'condition_grade',
            _selectedCondition!,
          );
        }
        if (_minPrice != null) {
          queryBuilder = queryBuilder.gte('point_price', _minPrice!);
        }
        if (_maxPrice != null) {
          queryBuilder = queryBuilder.lte('point_price', _maxPrice!);
        }
        if (_selectedCategory != null) {
          queryBuilder = queryBuilder.eq('category_id', _selectedCategory!);
        }

        final response = await queryBuilder.order(
          'registered_at',
          ascending: false,
        );
        _searchResults = (response as List)
            .map((json) => Book.fromJson(json))
            .toList();
      }

      _setSearching(false);
      notifyListeners();
    } catch (e) {
      _setError('검색 중 오류가 발생했습니다: ${e.toString()}');
      _setSearching(false);
    }
  }

  /// 추천 도서 가져오기
  Future<void> fetchRecommendedBooks(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      // book_status가 available이고 거래가 없거나 cancelled인 책만 최신순으로 10권 추천
      final allBooks = await Supabase.instance.client
          .from('book')
          .select()
          .eq('book_status', 'available') // 사물함 배정 완료된 책만
          .order('registered_at', ascending: false);

      // book_transaction에서 active, pending, completed 상태인 거래의 책 ID 조회
      final activeTransactions = await Supabase.instance.client
          .from('book_transaction')
          .select('book_id')
          .inFilter('trans_status', ['active', 'pending', 'completed']);

      final bookIdsInActiveTransaction = (activeTransactions as List)
          .map((e) => e['book_id'] as String)
          .toSet();

      // 진행 중인 거래가 없는 책만 필터링
      final response = (allBooks as List)
          .where(
            (book) => !bookIdsInActiveTransaction.contains(book['book_id']),
          )
          .take(10)
          .toList();

      _recommendedBooks = response.map((json) => Book.fromJson(json)).toList();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('추천 도서를 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 내가 등록한 책 목록 가져오기
  Future<void> fetchMyBooks(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('book')
          .select()
          .eq('user_id', userId)
          .order('registered_at', ascending: false);

      _myBooks = (response as List).map((json) => Book.fromJson(json)).toList();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('내 책 목록을 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 책에 배정된 사물함 ID 조회
  Future<String?> getAssignedLockerId(String bookId) async {
    try {
      final response = await Supabase.instance.client
          .from('locker')
          .select('locker_id')
          .eq('current_book_id', bookId)
          .maybeSingle();

      return response?['locker_id'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// 책 등록
  /// imageFile: 업로드할 이미지 파일 (선택적)
  /// 성공 시 등록된 Book 객체 반환, 실패 시 null 반환
  Future<Book?> registerBook(Book book, {XFile? imageFile}) async {
    try {
      _setLoading(true);
      _clearError();

      String? imageUrl;
      if (imageFile != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${book.userId}.jpg';
        imageUrl = await _supabaseService.uploadBookImage(imageFile, fileName);
      }

      final bookData = {
        // book_id는 Supabase가 자동 생성 (gen_random_uuid())
        'user_id': book.userId,
        'category_id': book.categoryId,
        'title': book.title,
        'author': book.author,
        'publisher': book.publisher,
        'point_price': book.pointPrice,
        'condition_grade': book.conditionGrade,
        'dmg_tag': book.dmgTag,
        'img_url': imageUrl ?? book.imgUrl,
        'registered_at': DateTime.now().toIso8601String(),
        'book_status': 'pending', // 명시적으로 pending 상태 설정
      };

      final response = await Supabase.instance.client
          .from('book')
          .insert(bookData)
          .select()
          .single();

      final newBook = Book.fromJson(response);
      _myBooks.add(newBook);
      _books.add(newBook);

      _setLoading(false);
      notifyListeners();
      return newBook;
    } catch (e) {
      _setError('책 등록 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  /// 책 정보 업데이트
  Future<bool> updateBook(Book book) async {
    try {
      _setLoading(true);
      _clearError();

      final updateData = {
        'category_id': book.categoryId,
        'title': book.title,
        'author': book.author,
        'publisher': book.publisher,
        'point_price': book.pointPrice,
        'condition_grade': book.conditionGrade,
        'dmg_tag': book.dmgTag,
        'img_url': book.imgUrl,
      };

      final response = await Supabase.instance.client
          .from('book')
          .update(updateData)
          .eq('book_id', book.id)
          .select()
          .single();

      final updatedBook = Book.fromJson(response);

      // 목록에서 업데이트
      _updateBookInList(_books, updatedBook);
      _updateBookInList(_myBooks, updatedBook);
      _updateBookInList(_searchResults, updatedBook);
      _updateBookInList(_recommendedBooks, updatedBook);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('책 정보 업데이트 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 책 삭제
  Future<bool> deleteBook(String bookId) async {
    String? deleteError;

    try {
      _setLoading(true);
      _clearError();

      // 진행 중인 거래 확인
      final activeTransactions = await Supabase.instance.client
          .from('book_transaction')
          .select()
          .eq('book_id', bookId)
          .inFilter('trans_status', ['active', 'pending']);

      if (activeTransactions.isNotEmpty) {
        deleteError = '진행 중인 거래가 있는 교재는 삭제할 수 없습니다.';
        _setLoading(false);
        _errorMessage = deleteError; // 에러 메시지만 저장 (notifyListeners 호출 안 함)
        return false;
      }

      await Supabase.instance.client
          .from('book')
          .delete()
          .eq('book_id', bookId);

      // 목록에서 제거
      _books.removeWhere((book) => book.id == bookId);
      _myBooks.removeWhere((book) => book.id == bookId);
      _searchResults.removeWhere((book) => book.id == bookId);
      _recommendedBooks.removeWhere((book) => book.id == bookId);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      // PostgreSQL 외래 키 오류 처리
      if (e.toString().contains('foreign key') ||
          e.toString().contains('violates')) {
        deleteError = '진행 중인 거래가 있는 교재는 삭제할 수 없습니다.';
      } else {
        deleteError = '책 삭제 중 오류가 발생했습니다.';
      }
      _setLoading(false);
      _errorMessage = deleteError; // 에러 메시지만 저장 (notifyListeners 호출 안 함)
      return false;
    }
  }

  /// 책 상태 업데이트 (pending, available, sold, deleted)
  Future<bool> updateBookStatus(String bookId, String newStatus) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('book')
          .update({'book_status': newStatus})
          .eq('book_id', bookId)
          .select()
          .single();

      final updatedBook = Book.fromJson(response);

      // 목록에서 업데이트
      _updateBookInList(_books, updatedBook);
      _updateBookInList(_myBooks, updatedBook);
      _updateBookInList(_searchResults, updatedBook);
      _updateBookInList(_recommendedBooks, updatedBook);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('책 상태 업데이트 실패: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 검색 필터 설정
  void setSearchFilters({
    String? condition, // "excellent", "good", "fair", "poor"
    int? minPrice,
    int? maxPrice,
    String? category,
  }) {
    _selectedCondition = condition;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _selectedCategory = category;
    notifyListeners();
  }

  /// 검색 필터 초기화
  void clearSearchFilters() {
    _selectedCondition = null;
    _minPrice = null;
    _maxPrice = null;
    _selectedCategory = null;
    notifyListeners();
  }

  /// 검색 결과 초기화
  void clearSearchResults() {
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }

  /// 특정 책 가져오기
  Future<Book?> getBook(String bookId) async {
    try {
      final response = await Supabase.instance.client
          .from('book')
          .select()
          .eq('book_id', bookId)
          .single();
      return Book.fromJson(response);
    } catch (e) {
      _setError('책 정보를 불러오는데 실패했습니다: ${e.toString()}');
      return null;
    }
  }

  /// ISBN으로 책 정보 검색
  Future<Book?> searchBookByISBN(String isbn) async {
    try {
      // ISBN 필드가 Book 모델에 없으므로 title로 검색
      final response = await Supabase.instance.client
          .from('book')
          .select()
          .ilike('title', '%$isbn%')
          .maybeSingle();
      return response != null ? Book.fromJson(response) : null;
    } catch (e) {
      _setError('ISBN 검색 중 오류가 발생했습니다: ${e.toString()}');
      return null;
    }
  }

  /// 책 목록에서 업데이트
  void _updateBookInList(List<Book> list, Book updatedBook) {
    final index = list.indexWhere((book) => book.id == updatedBook.id);
    if (index != -1) {
      list[index] = updatedBook;
    }
  }

  /// 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 검색 중 상태 설정
  void _setSearching(bool searching) {
    _isSearching = searching;
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
