import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  final Dio _dio = Dio();

  // TODO: 실제 OCR 서버 URL로 변경 필요
  static const String _ocrServerUrl = 'http://192.168.0.13:8000/predict';

  /// 이미지에서 교재 정보 추출
  Future<Map<String, dynamic>> extractBookInfo(XFile imageFile) async {
    try {
      // 캡처된 이미지 바이트 읽기 (웹/모바일 호환)
      final bytes = await imageFile.readAsBytes();

      // FormData로 이미지 전송 준비
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: imageFile.name.isNotEmpty ? imageFile.name : 'image.jpg',
        ),
      });

      // OCR 서버에 요청
      final response = await _dio.post(
        _ocrServerUrl,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        // 서버 응답에서 교재 정보 추출
        final data = response.data;

        // success 필드 확인
        final success = data['success'] as bool? ?? false;

        if (success == false) {
          // OCR 실패 시
          throw Exception('이미지에서 교재 정보를 인식할 수 없습니다. 다시 촬영해주세요.');
        }

        return {
          'title': data['title'] as String? ?? '',
          'author': data['author'] as String? ?? '',
          'publisher': data['publisher'] as String? ?? '',
          'condition_status': data['condition_status'], // 책 상태 (최상/상/중/하)
          'dmg_tag': data['dmg_tag'], // 결함 태그 리스트
        };
      } else {
        throw Exception('OCR 서버 응답 오류: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('서버 연결 시간 초과');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('서버에 연결할 수 없습니다');
      } else {
        throw Exception('OCR 처리 실패: ${e.message}');
      }
    } catch (e) {
      throw Exception('OCR 처리 중 오류 발생: $e');
    }
  }

  /// 임시 테스트용 Mock 데이터 반환
  Future<Map<String, dynamic>> extractBookInfoMock(XFile imageFile) async {
    // 실제 OCR 서버가 준비되기 전까지 사용할 임시 데이터
    await Future.delayed(const Duration(seconds: 2)); // 서버 응답 시뮬레이션

    // 테스트: success = true인 경우
    final mockResponse = {
      'success': true,
      'title': '데이터베이스 개론',
      'author': '김연희',
      'publisher': '한빛아카데미',
      'condition_status': '상', // 책 상태 (최상/상/중/하)
      'dmg_tag': ['앞표지 구겨짐', '3페이지 낙서'], // 결함 태그 리스트
    };

    // success 필드 확인
    final success = mockResponse['success'] as bool? ?? false;

    if (success == false) {
      throw Exception('이미지에서 교재 정보를 인식할 수 없습니다. 다시 촬영해주세요.');
    }

    return {
      'title': mockResponse['title'] as String? ?? '',
      'author': mockResponse['author'] as String? ?? '',
      'publisher': mockResponse['publisher'] as String? ?? '',
      'condition_status': mockResponse['condition_status'], // 책 상태 (최상/상/중/하)
      'dmg_tag': mockResponse['dmg_tag'], // 결함 태그 리스트
    };
  }
}
