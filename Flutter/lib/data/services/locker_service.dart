import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 라즈베리파이 서보모터를 이용한 사물함 제어 서비스
/// Capstone 프로젝트의 서보모터 제어 API와 연동
class LockerService {
  final Dio _dio = Dio();

  /// 환경 변수에서 라즈베리파이 서버 URL 가져오기
  static String get _baseUrl =>
      dotenv.env['RASPBERRY_PI_URL'] ?? 'http://192.168.0.13:8080/api';

  /// 타임아웃 설정 (10초)
  static const Duration _timeout = Duration(seconds: 10);

  /// 사물함 번호와 서보모터 매핑
  /// 사물함 1번 → 서보모터 1번 (GPIO 17)
  /// 사물함 2번 → 서보모터 2번 (GPIO 27)
  /// 사물함 3번 → 서보모터 3번 (GPIO 22)
  /// 사물함 4번 → 서보모터 4번 (GPIO 23)
  int _getServoNumber(int lockerNum) {
    if (lockerNum < 1 || lockerNum > 4) {
      throw ArgumentError('사물함 번호는 1~4 사이여야 합니다. 입력값: $lockerNum');
    }
    return lockerNum;
  }

  /// 서버 상태 확인
  Future<bool> checkConnection() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/health',
        options: Options(receiveTimeout: _timeout),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 사물함 열기 (서보모터 ON)
  /// @param lockerNum 사물함 번호 (1~4)
  /// @return 성공 여부
  Future<bool> openLocker(int lockerNum) async {
    try {
      final servoNo = _getServoNumber(lockerNum);

      final response = await _dio.post(
        '$_baseUrl/signal',
        data: {
          'survoNo': servoNo,
          'status': false, // false = 열림
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: _timeout,
          sendTimeout: _timeout,
        ),
      );

      if (response.statusCode == 200) {
        // 서버 응답 형식이 다양할 수 있으므로 200 응답을 성공으로 간주
        return true;
      }

      return false;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('서버 연결 시간 초과');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('서버에 연결할 수 없습니다');
      } else {
        throw Exception('사물함 열기 실패: ${e.message}');
      }
    } catch (e) {
      throw Exception('사물함 열기 중 오류 발생: $e');
    }
  }

  /// 사물함 닫기 (서보모터 OFF)
  /// @param lockerNum 사물함 번호 (1~4)
  /// @return 성공 여부
  Future<bool> closeLocker(int lockerNum) async {
    try {
      final servoNo = _getServoNumber(lockerNum);

      final response = await _dio.post(
        '$_baseUrl/signal',
        data: {
          'survoNo': servoNo,
          'status': true, // true = 닫힘
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout: _timeout,
          sendTimeout: _timeout,
        ),
      );

      if (response.statusCode == 200) {
        // 서버 응답 형식이 다양할 수 있으므로 200 응답을 성공으로 간주
        return true;
      }

      return false;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('서버 연결 시간 초과');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('서버에 연결할 수 없습니다');
      } else {
        throw Exception('사물함 닫기 실패: ${e.message}');
      }
    } catch (e) {
      throw Exception('사물함 닫기 중 오류 발생: $e');
    }
  }

  /// 사물함 토글 (열림 ↔ 닫힘)
  /// @param lockerNum 사물함 번호 (1~4)
  /// @param isOpen 현재 열림 상태
  /// @return 성공 여부
  Future<bool> toggleLocker(int lockerNum, bool isOpen) async {
    if (isOpen) {
      return await closeLocker(lockerNum);
    } else {
      return await openLocker(lockerNum);
    }
  }

  /// 모든 사물함 닫기 (비상 상황)
  Future<Map<int, bool>> closeAllLockers() async {
    final results = <int, bool>{};

    for (int i = 1; i <= 4; i++) {
      try {
        results[i] = await closeLocker(i);
      } catch (e) {
        results[i] = false;
      }
    }

    return results;
  }

  /// 사물함 상태 확인 (서버에서 현재 상태 조회)
  /// Spring Boot 서버의 GET /api 엔드포인트 사용
  Future<Map<int, bool>> getLockerStates() async {
    try {
      final response = await _dio.get(
        _baseUrl,
        options: Options(receiveTimeout: _timeout),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // {"1": false, "2": true, "3": false, "4": false}
        return {
          1: data['1'] as bool? ?? false,
          2: data['2'] as bool? ?? false,
          3: data['3'] as bool? ?? false,
          4: data['4'] as bool? ?? false,
        };
      }

      return {1: false, 2: false, 3: false, 4: false};
    } catch (e) {
      throw Exception('사물함 상태 조회 실패: $e');
    }
  }

  /// 서보모터 초기화 (모두 닫힌 상태로)
  Future<bool> initializeLockers() async {
    try {
      final results = await closeAllLockers();
      return results.values.every((success) => success);
    } catch (e) {
      return false;
    }
  }
}
