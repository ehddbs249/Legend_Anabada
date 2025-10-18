import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_point_balance.dart';
import '../models/point_transaction.dart';

/// 포인트 관련 상태 관리 Provider
class PointProvider with ChangeNotifier {
  UserPointBalance? _currentBalance;
  List<PointTransaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Getters
  UserPointBalance? get currentBalance => _currentBalance;
  List<PointTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 포인트 잔액 조회
  Future<void> fetchBalance(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('user_point_balance')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        _currentBalance = UserPointBalance.fromJson(response);
      } else {
        // 레코드가 없으면 0포인트로 초기화
        _currentBalance = UserPointBalance(userId: userId, pointTotal: 0);
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('잔액 조회 실패: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 포인트 거래 내역 조회
  Future<void> fetchTransactions(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('point_transaction')
          .select()
          .eq('user_id', userId)
          .order('trans_date', ascending: false)
          .limit(50);

      _transactions = (response as List)
          .map((json) => PointTransaction.fromJson(json))
          .toList();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('거래 내역 조회 실패: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 획득 포인트 합계 - DB에서 가져오기
  int get totalEarned {
    return _currentBalance?.totalEarned ?? 0;
  }

  /// 사용 포인트 합계 - DB에서 가져오기
  int get totalSpent {
    return _currentBalance?.totalSpent ?? 0;
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
  }

  /// 에러 지우기 (외부에서 호출 가능)
  void clearError() {
    _clearError();
    notifyListeners();
  }

  /// Provider 초기화
  void clear() {
    _currentBalance = null;
    _transactions = [];
    _errorMessage = null;
    notifyListeners();
  }
}
