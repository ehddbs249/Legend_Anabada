import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/services/ocr_service.dart';

class OcrCameraScreen extends StatefulWidget {
  const OcrCameraScreen({super.key});

  @override
  State<OcrCameraScreen> createState() => _OcrCameraScreenState();
}

class _OcrCameraScreenState extends State<OcrCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isPhotoTaken = false;
  XFile? _capturedImage;
  bool _isProcessing = false;
  final OcrService _ocrService = OcrService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  /// 카메라 초기화
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          _showErrorSnackBar('사용 가능한 카메라가 없습니다.');
          context.pop();
        }
        return;
      }

      // 후면 카메라 선택 (없으면 첫 번째 카메라)
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('카메라를 초기화할 수 없습니다: $e');
        context.pop();
      }
    }
  }

  /// 사진 촬영
  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();

      setState(() {
        _capturedImage = image;
        _isPhotoTaken = true;
      });
    } catch (e) {
      _showErrorSnackBar('사진 촬영에 실패했습니다: $e');
    }
  }

  /// 재촬영
  Future<void> _retakePicture() async {
    setState(() {
      _capturedImage = null;
      _isPhotoTaken = false;
      _isCameraInitialized = false;
    });

    // 카메라 재초기화
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    await _initializeCamera();
  }

  /// OCR 처리
  Future<void> _processOcr() async {
    if (_capturedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // TODO: 실제 OCR 서버가 준비되면 extractBookInfo로 변경
      final result = await _ocrService.extractBookInfo(_capturedImage!);
      // final result = await _ocrService.extractBookInfoMock(_capturedImage!);

      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        _showResultDialog(result);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  /// 결과 다이얼로그 표시
  void _showResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('OCR 결과'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResultItem('제목', result['title'] ?? '인식되지 않음'),
              const SizedBox(height: 8),
              _buildResultItem('저자', result['author'] ?? '인식되지 않음'),
              const SizedBox(height: 8),
              _buildResultItem('출판사', result['publisher'] ?? '인식되지 않음'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // OCR 결과와 촬영한 이미지를 함께 전달
              final dataToPass = {...result, 'capturedImage': _capturedImage};
              context.go('/register', extra: dataToPass);
            },
            child: const Text('등록하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 에러 다이얼로그 표시
  void _showErrorDialog(String errorMessage) {
    final message = errorMessage.replaceFirst('Exception: ', '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 28),
            SizedBox(width: 12),
            Text('OCR 실패'),
          ],
        ),
        content: Text(message),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _retakePicture();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    '재촬영',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/home');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.textSecondary),
                  ),
                  child: const Text('홈으로'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 에러 스낵바 표시
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  /// 카메라 프리뷰 화면
  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 카메라 프리뷰
        CameraPreview(_cameraController!),

        // 촬영 버튼
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _takePicture,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.primary, width: 4),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 35,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 촬영된 사진 미리보기 화면
  Widget _buildPhotoPreview() {
    if (_capturedImage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: FutureBuilder<Uint8List>(
                future: _capturedImage!.readAsBytes(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image.memory(snapshot.data!, fit: BoxFit.contain);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              if (_isProcessing)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'OCR 처리 중...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _retakePicture,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '재촬영',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _processOcr,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'OCR 처리',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_isPhotoTaken ? '촬영 확인' : '책 표지 촬영'),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: _isPhotoTaken ? _buildPhotoPreview() : _buildCameraPreview(),
    );
  }
}
