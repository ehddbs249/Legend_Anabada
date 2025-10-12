import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

/// 거래 관련 상태 관리 Provider
class TransactionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

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

      _transactions = await _apiService.getTransactions();
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

      _myLendingTransactions = await _apiService.getLendingTransactions(userId);
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

      _myBorrowingTransactions = await _apiService.getBorrowingTransactions(userId);
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

      _activeTransactions = await _apiService.getActiveTransactions(userId);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('진행 중인 거래를 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 거래 생성 (책 대여 요청)
  Future<bool> createTransaction({
    required String bookId,
    required String borrowerId,
    required int rentalDays,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final transaction = await _apiService.createTransaction(
        bookId: bookId,
        borrowerId: borrowerId,
        rentalDays: rentalDays,
        notes: notes,
      );

      _transactions.add(transaction);
      _activeTransactions.add(transaction);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('거래 생성 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 거래 승인
  Future<bool> approveTransaction(String transactionId) async {
    try {
      _setLoading(true);
      _clearError();

      final transaction = await _apiService.approveTransaction(transactionId);
      _updateTransactionInLists(transaction);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('거래 승인 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 거래 거절
  Future<bool> rejectTransaction(String transactionId, String reason) async {
    try {
      _setLoading(true);
      _clearError();

      final transaction = await _apiService.rejectTransaction(transactionId, reason);
      _updateTransactionInLists(transaction);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('거래 거절 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 거래 완료 (책 반납)
  Future<bool> completeTransaction(String transactionId) async {
    try {
      _setLoading(true);
      _clearError();

      final transaction = await _apiService.completeTransaction(transactionId);
      _updateTransactionInLists(transaction);

      // 활성 거래에서 제거
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

      final transaction = await _apiService.cancelTransaction(transactionId);
      _updateTransactionInLists(transaction);

      // 활성 거래에서 제거
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

  /// 사물함 배정
  /// NOTE: Locker 모델의 lockerId 타입이 int에서 String으로 변경되었습니다.
  Future<bool> assignLocker(String transactionId, String lockerId) async {
    try {
      _setLoading(true);
      _clearError();

      final transaction = await _apiService.assignLocker(transactionId, lockerId);
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

  /// 특정 거래 가져오기
  Future<Transaction?> getTransaction(String transactionId) async {
    try {
      return await _apiService.getTransaction(transactionId);
    } catch (e) {
      _setError('거래 정보를 불러오는데 실패했습니다: ${e.toString()}');
      return null;
    }
  }

  /// 연체된 거래 목록 가져오기
  /// NOTE: Transaction 모델에서 isOverdue, dueDate, returnedAt 필드가 제거되었습니다.
  /// 현재 Transaction 모델은 trans_status 필드만 제공합니다.
  /// 연체 여부는 백엔드 API에서 'overdue' 상태로 관리됩니다.
  List<Transaction> getOverdueTransactions() {
    return _activeTransactions.where((transaction) {
      return transaction.transStatus == 'overdue';
    }).toList();
  }

  /// 곧 만료되는 거래 목록 가져오기 (3일 이내)
  /// NOTE: Transaction 모델에 dueDate 필드가 없으므로 백엔드에서 관리해야 합니다.
  /// 현재는 'active' 상태의 거래만 반환합니다.
  /// TODO: 백엔드 API에서 만료 임박 거래를 별도로 제공하도록 수정 필요
  List<Transaction> getExpiringTransactions() {
    // 백엔드 API에서 만료 임박 정보를 제공하도록 수정 필요
    return _activeTransactions.where((transaction) {
      return transaction.transStatus == 'active';
    }).toList();
  }

  /// 거래 통계 계산
  /// NOTE: Transaction 모델의 필드명이 변경되었습니다:
  /// - lenderId → userId (거래를 시작한 사용자)
  /// - TransactionStatus enum → String 타입의 transStatus 필드
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

  /// 포인트 내역 가져오기
  Future<List<Map<String, dynamic>>> getPointHistory(String userId) async {
    try {
      return await _apiService.getPointHistory(userId);
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