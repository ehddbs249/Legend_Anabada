import 'package:flutter/foundation.dart';
import '../models/locker.dart';
import '../services/api_service.dart';

/// 사물함 관련 상태 관리 Provider
class LockerProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

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

      _lockers = await _apiService.getLockers();
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

      _availableLockers = await _apiService.getAvailableLockers();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('사용 가능한 사물함을 불러오는데 실패했습니다: ${e.toString()}');
      _setLoading(false);
    }
  }

  /// 특정 사물함 정보 가져오기
  /// lockerId는 UUID String입니다.
  Future<Locker?> getLocker(String lockerId) async {
    try {
      _setLoading(true);
      _clearError();

      final locker = await _apiService.getLocker(lockerId);
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
  /// lockerId는 UUID String입니다.
  Future<bool> reserveLocker(String lockerId, String transactionId) async {
    try {
      _setLoading(true);
      _clearError();

      final locker = await _apiService.reserveLocker(lockerId, transactionId);
      _updateLockerInLists(locker);

      // 사용 가능한 사물함 목록에서 제거
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
  /// lockerId는 UUID String입니다.
  Future<bool> releaseLocker(String lockerId) async {
    try {
      _setLoading(true);
      _clearError();

      final locker = await _apiService.releaseLocker(lockerId);
      _updateLockerInLists(locker);

      // 사용 가능한 사물함 목록에 추가
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
  /// lockerId는 UUID String입니다.
  /// NOTE: Locker 모델에 lastAccessed 필드가 제거되었습니다.
  Future<bool> openLocker(String lockerId, String accessCode) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _apiService.openLocker(lockerId, accessCode);

      // lastAccessed 필드는 Locker 모델에서 제거되었으므로
      // SystemLog를 통해 접근 이력을 추적해야 합니다.

      _setLoading(false);
      notifyListeners();
      return success;
    } catch (e) {
      _setError('사물함 열기 중 오류가 발생했습니다: ${e.toString()}');
      _setLoading(false);
      return false;
    }
  }

  /// 사물함 상태 업데이트
  /// lockerId는 UUID String입니다.
  /// status: "available", "occupied", "maintenance"
  Future<bool> updateLockerStatus(String lockerId, String status) async {
    try {
      _setLoading(true);
      _clearError();

      final locker = await _apiService.updateLockerStatus(lockerId, status);
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

  /// 사물함 접근 코드 생성
  /// lockerId는 UUID String입니다.
  /// NOTE: Locker 모델에 accessCode 필드가 제거되었습니다.
  /// 접근 코드는 Transaction 또는 별도 API로 관리됩니다.
  @Deprecated('accessCode는 Locker 모델에서 제거되었습니다. Transaction API를 사용하세요.')
  Future<String?> generateAccessCode(String lockerId, String transactionId) async {
    try {
      _setLoading(true);
      _clearError();

      final accessCode = await _apiService.generateLockerAccessCode(lockerId, transactionId);

      // accessCode 필드는 Locker 모델에 없습니다.
      // Transaction API를 통해 접근 코드를 관리하세요.

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
  /// NOTE: Locker 모델에 location, position 필드가 제거되었습니다.
  /// lockerNum을 기반으로 계산하거나, 별도 UI 로직으로 처리해야 합니다.
  @Deprecated('location, position 필드가 제거되었습니다. lockerNum으로 그리드를 계산하세요.')
  List<List<Locker?>> getLockerGrid(String location) {
    // location 필드가 Locker 모델에서 제거되었습니다.
    // lockerNum을 2x2 그리드로 매핑하는 로직으로 대체하세요.

    // 예시: lockerNum 1~4를 2x2 그리드로 변환
    // 1 → (0, 0), 2 → (0, 1), 3 → (1, 0), 4 → (1, 1)

    List<List<Locker?>> grid = List.generate(2, (index) => List.filled(2, null));

    for (final locker in _lockers) {
      if (locker.lockerNum != null) {
        final num = locker.lockerNum! - 1; // 0-based index
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
  /// NOTE: Locker 모델에 status enum이 제거되었습니다. String으로 비교합니다.
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
  /// NOTE: Locker 모델에 location 필드가 제거되었습니다.
  /// 하드코딩된 위치 목록을 반환하거나, 별도 설정에서 가져와야 합니다.
  @Deprecated('location 필드가 제거되었습니다. 하드코딩된 위치 목록 또는 설정 파일을 사용하세요.')
  List<String> getLockerLocations() {
    // location 필드가 없으므로, 하드코딩된 위치 반환
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
