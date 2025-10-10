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
  Future<Locker?> getLocker(int lockerId) async {
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
  Future<bool> reserveLocker(int lockerId, String transactionId) async {
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
  Future<bool> releaseLocker(int lockerId) async {
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
  Future<bool> openLocker(int lockerId, String accessCode) async {
    try {
      _setLoading(true);
      _clearError();

      final success = await _apiService.openLocker(lockerId, accessCode);

      if (success) {
        // 마지막 접근 시간 업데이트
        final lockerIndex = _lockers.indexWhere((l) => l.id == lockerId);
        if (lockerIndex != -1) {
          _lockers[lockerIndex] = _lockers[lockerIndex].copyWith(
            lastAccessed: DateTime.now(),
          );
        }

        if (_selectedLocker?.id == lockerId) {
          _selectedLocker = _selectedLocker!.copyWith(
            lastAccessed: DateTime.now(),
          );
        }
      }

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
  Future<bool> updateLockerStatus(int lockerId, LockerStatus status) async {
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
  Future<String?> generateAccessCode(int lockerId, String transactionId) async {
    try {
      _setLoading(true);
      _clearError();

      final accessCode = await _apiService.generateLockerAccessCode(lockerId, transactionId);

      // 선택된 사물함의 접근 코드 업데이트
      if (_selectedLocker?.id == lockerId) {
        _selectedLocker = _selectedLocker!.copyWith(accessCode: accessCode);
      }

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
  List<List<Locker?>> getLockerGrid(String location) {
    final locationLockers = _lockers.where((l) => l.location == location).toList();

    // 2x2 그리드 초기화
    List<List<Locker?>> grid = List.generate(2, (index) => List.filled(2, null));

    // 사물함을 그리드에 배치
    for (final locker in locationLockers) {
      if (locker.position.row < 2 && locker.position.column < 2) {
        grid[locker.position.row][locker.position.column] = locker;
      }
    }

    return grid;
  }

  /// 사물함 통계
  Map<String, int> getLockerStats() {
    final available = _lockers.where((l) => l.status == LockerStatus.available).length;
    final occupied = _lockers.where((l) => l.status == LockerStatus.occupied).length;
    final maintenance = _lockers.where((l) => l.status == LockerStatus.maintenance).length;
    final broken = _lockers.where((l) => l.status == LockerStatus.broken).length;

    return {
      'available': available,
      'occupied': occupied,
      'maintenance': maintenance,
      'broken': broken,
      'total': _lockers.length,
    };
  }

  /// 사물함 위치 목록 가져오기
  List<String> getLockerLocations() {
    return _lockers.map((l) => l.location).toSet().toList();
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