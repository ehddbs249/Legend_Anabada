import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/locker.dart';

/// 사물함 관련 상태 관리 Provider
class LockerProvider with ChangeNotifier {
  List<Locker> _lockers = [];
  List<Locker> _availableLockers = [];
  Locker? _selectedLocker;

  bool _isLoading = false;
  String? _errorMessage;

  /// Getter 들
  List<Locker> get lockers => _lockers;
  List<Locker> get availableLockers => _availableLockers;
  Locker? get selectedLocker => _selectedLocker;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 전체 사물함 목록 가져오기
  Future<void> fetchLockers() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('locker')
          .select()
          .order('locker_num', ascending: true);

      _lockers = (response as List).map((json) => Locker.fromJson(json)).toList();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('사물함 목록을 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 사용 가능한 사물함 목록 가져오기
  Future<void> fetchAvailableLockers() async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('locker')
          .select()
          .eq('locker_status', 'available')
          .order('locker_num', ascending: true);

      _availableLockers = (response as List).map((json) => Locker.fromJson(json)).toList();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('사용 가능한 사물함을 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 특정 사물함 정보 가져오기
  Future<Locker?> getLocker(String lockerId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('locker')
          .select()
          .eq('locker_id', lockerId)
          .single();

      final locker = Locker.fromJson(response);
      _selectedLocker = locker;

      _setLoading(false);
      notifyListeners();
      return locker;
    } catch (e) {
      _setError('사물함 정보를 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  /// 사물함 예약
  Future<bool> reserveLocker(String lockerId, String transactionId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('locker')
          .update({
            'locker_status': 'occupied',
            'trans_id': transactionId,
          })
          .eq('locker_id', lockerId)
          .select()
          .single();

      final locker = Locker.fromJson(response);
      _updateLockerInLists(locker);
      _availableLockers.removeWhere((l) => l.id == lockerId);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('사물함 예약 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 사물함 반납
  Future<bool> releaseLocker(String lockerId) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('locker')
          .update({
            'locker_status': 'available',
            'trans_id': null,
          })
          .eq('locker_id', lockerId)
          .select()
          .single();

      final locker = Locker.fromJson(response);
      _updateLockerInLists(locker);

      if (locker.isAvailable) {
        _availableLockers.add(locker);
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('사물함 반납 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 사물함 열기 (접근 코드 검증)
  Future<bool> openLocker(String lockerId, String accessCode) async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: 접근 코드 검증 로직 구현 (Transaction 테이블과 연동)
      // 현재는 간단하게 성공 반환

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('사물함 열기 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 사물함 상태 업데이트
  Future<bool> updateLockerStatus(String lockerId, String status) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await Supabase.instance.client
          .from('locker')
          .update({'locker_status': status})
          .eq('locker_id', lockerId)
          .select()
          .single();

      final locker = Locker.fromJson(response);
      _updateLockerInLists(locker);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('사물함 상태 업데이트 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 사물함 접근 코드 생성 (미구현)
  @Deprecated('Transaction API를 사용하세요')
  Future<String?> generateAccessCode(String lockerId, String transactionId) async {
    try {
      _setLoading(true);
      _clearError();

      // TODO: Transaction 테이블에서 접근 코드 생성
      final accessCode = DateTime.now().millisecondsSinceEpoch.toString().substring(6);

      _setLoading(false);
      notifyListeners();
      return accessCode;
    } catch (e) {
      _setError('접근 코드 생성 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  /// 특정 위치의 사물함 그리드 가져오기 (2x2)
  @Deprecated('lockerNum으로 그리드를 계산하세요')
  List<List<Locker?>> getLockerGrid(String location) {
    List<List<Locker?>> grid = List.generate(2, (index) => List.filled(2, null));

    for (final locker in _lockers) {
      if (locker.lockerNum != null) {
        final num = locker.lockerNum! - 1;
        if (num >= 0 && num < 4) {
          final row = num ~/ 2;
          final col = num % 2;
          grid[row][col] = locker;
        }
      }
    }

    return grid;
  }

  /// 사물함 통계
  Map<String, int> getLockerStats() {
    final available = _lockers.where((l) => l.lockerStatus == 'available').length;
    final occupied = _lockers.where((l) => l.lockerStatus == 'occupied').length;
    final maintenance = _lockers.where((l) => l.lockerStatus == 'maintenance').length;
    final broken = _lockers.where((l) => l.isBroken == true).length;

    return {
      'available': available,
      'occupied': occupied,
      'maintenance': maintenance,
      'broken': broken,
      'total': _lockers.length,
    };
  }

  /// 사물함 위치 목록 가져오기
  @Deprecated('하드코딩된 위치 목록을 사용하세요')
  List<String> getLockerLocations() {
    return ['1층 로비', '2층 복도', '3층 휴게실'];
  }

  /// 선택된 사물함 설정
  void setSelectedLocker(Locker? locker) {
    _selectedLocker = locker;
    notifyListeners();
  }

  /// 선택된 사물함 초기화
  void clearSelectedLocker() {
    _selectedLocker = null;
    notifyListeners();
  }

  /// 모든 목록에서 사물함 업데이트
  void _updateLockerInLists(Locker updatedLocker) {
    _updateLockerInList(_lockers, updatedLocker);
    _updateLockerInList(_availableLockers, updatedLocker);

    if (_selectedLocker?.id == updatedLocker.id) {
      _selectedLocker = updatedLocker;
    }
  }

  /// 특정 목록에서 사물함 업데이트
  void _updateLockerInList(List<Locker> list, Locker updatedLocker) {
    final index = list.indexWhere((locker) => locker.id == updatedLocker.id);
    if (index != -1) {
      list[index] = updatedLocker;
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
