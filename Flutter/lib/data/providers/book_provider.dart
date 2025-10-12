import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/api_service.dart';

/// 책 관련 상태 관리 Provider
class BookProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Book> _books = [];
  List<Book> _searchResults = [];
  List<Book> _myBooks = [];
  List<Book> _recommendedBooks = [];

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;

  // 검색 필터
  String _searchQuery = '';
  String? _selectedCondition; // condition grade: "excellent", "good", "fair", "poor"
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

      _books = await _apiService.getBooks();
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
        _searchResults = await _apiService.searchBooks(
          query: query,
          condition: _selectedCondition,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          category: _selectedCategory,
        );
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

      _recommendedBooks = await _apiService.getRecommendedBooks(userId);
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

      _myBooks = await _apiService.getMyBooks(userId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('내 책 목록을 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 책 등록
  /// imageFile: 업로드할 이미지 파일 (선택적)
  Future<bool> registerBook(Book book, {File? imageFile}) async {
    try {
      _setLoading(true);
      _clearError();

      final newBook = await _apiService.createBook(book, imageFile: imageFile);
      _myBooks.add(newBook);
      _books.add(newBook);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('책 등록 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 책 정보 업데이트
  Future<bool> updateBook(Book book) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedBook = await _apiService.updateBook(book);

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
    try {
      _setLoading(true);
      _clearError();

      await _apiService.deleteBook(bookId);

      // 목록에서 제거
      _books.removeWhere((book) => book.id == bookId);
      _myBooks.removeWhere((book) => book.id == bookId);
      _searchResults.removeWhere((book) => book.id == bookId);
      _recommendedBooks.removeWhere((book) => book.id == bookId);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('책 삭제 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 책 상태 업데이트 (대여, 반납 등)
  /// @Deprecated: Book 모델에 status 필드가 제거되었습니다.
  /// 책의 대여 상태는 BookTransaction을 통해 추적됩니다.
  @Deprecated('Use BookTransaction to track rental status instead')
  Future<bool> updateBookStatus(String bookId, String status) async {
    try {
      _setLoading(true);
      _clearError();

      // 더 이상 사용되지 않음 - BookTransaction으로 상태 추적
      // await _apiService.updateBookStatus(bookId, status);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('책 상태 업데이트 중 오류가 발생했습니다: ${e.toString()}');
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
      return await _apiService.getBook(bookId);
    } catch (e) {
      _setError('책 정보를 불러오는데 실패했습니다: ${e.toString()}');
      return null;
    }
  }

  /// ISBN으로 책 정보 검색
  Future<Book?> searchBookByISBN(String isbn) async {
    try {
      return await _apiService.searchBookByISBN(isbn);
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