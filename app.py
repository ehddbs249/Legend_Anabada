"""
통합 Flask 서버 - OCR & YOLO 처리
Spring Boot로부터 이미지를 받아 OCR과 YOLO 분석을 수행하고 결과를 반환
"""
from flask import Flask, request, jsonify, render_template, send_from_directory
from werkzeug.utils import secure_filename
import os
import sys
import json
from pathlib import Path

# 프로젝트 경로 설정
PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
OCR_DIR = os.path.join(PROJECT_ROOT, 'OCR')
YOLO_DIR = os.path.join(PROJECT_ROOT, 'YOLO')
UPLOAD_FOLDER = os.path.join(PROJECT_ROOT, 'uploads')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'bmp'}

# uploads 폴더 생성
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# OCR 모듈 경로 추가
sys.path.insert(0, OCR_DIR)
sys.path.insert(0, YOLO_DIR)

# OCR 및 YOLO 모듈 임포트
from OCR.ocr_service import OCRService
from YOLO.yolo_predict import predict_damage

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB 제한

# OCR 서비스 초기화 (서버 시작 시 한 번만)
print("Initializing OCR Service...")
ocr_service = OCRService(
    languages=['ko', 'en'],
    gpu=False,  # GPU 사용 여부 (환경에 맞게 설정)
    recog_network='custom'
)
print("OCR Service initialized.")


def allowed_file(filename):
    """허용된 파일 확장자 검사"""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/')
def index():
    """테스트 UI 페이지"""
    return render_template('test_upload.html')


@app.route('/health', methods=['GET'])
def health_check():
    """헬스 체크 엔드포인트"""
    return jsonify({
        'status': 'healthy',
        'service': 'OCR & YOLO Integration'
    }), 200


@app.route('/process', methods=['POST'])
def process_image():
    """
    이미지 처리 엔드포인트

    요청: multipart/form-data 형식의 이미지 파일
    응답: {
        "title": string,
        "author": string,
        "publisher": string,
        "dmg_tag": string
    }
    """
    # 파일 검증
    if 'file' not in request.files:
        return jsonify({
            'error': 'No file part in request'
        }), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({
            'error': 'No file selected'
        }), 400

    if not allowed_file(file.filename):
        return jsonify({
            'error': 'Invalid file type. Allowed types: png, jpg, jpeg, gif, bmp'
        }), 400

    try:
        # 파일 저장
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        # OCR 처리
        print(f"Processing OCR for {filename}...")
        try:
            ocr_result = ocr_service.process_image(filepath)
            print(f"OCR result type: {type(ocr_result)}")
            print(f"OCR result keys: {ocr_result.keys() if isinstance(ocr_result, dict) else 'Not a dict'}")
        except Exception as ocr_error:
            print(f"OCR Error: {str(ocr_error)}")
            import traceback
            traceback.print_exc()
            return jsonify({
                'error': f"OCR processing failed: {str(ocr_error)}"
            }), 500

        if not ocr_result.get('success', False):
            return jsonify({
                'error': f"OCR processing failed: {ocr_result.get('error', 'Unknown error')}"
            }), 500

        # YOLO 처리
        print(f"Processing YOLO for {filename}...")
        try:
            dmg_tag = predict_damage(filepath)
        except Exception as yolo_error:
            print(f"YOLO Error: {str(yolo_error)}")
            dmg_tag = "상"  # 기본값

        # 결과 조합
        response = {
            'title': ocr_result.get('title', ''),
            'author': ocr_result.get('author', ''),
            'publisher': ocr_result.get('publisher', ''),
            'dmg_tag': dmg_tag
        }

        print(f"Processing completed for {filename}")
        print(f"Result: {json.dumps(response, ensure_ascii=False)}")

        # 임시 파일 삭제 (선택사항)
        # os.remove(filepath)

        return jsonify(response), 200

    except Exception as e:
        print(f"Error processing image: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({
            'error': f'Internal server error: {str(e)}'
        }), 500


@app.route('/process/debug', methods=['POST'])
def process_image_debug():
    """
    디버그용 엔드포인트 - 상세한 결과 포함
    """
    if 'file' not in request.files:
        return jsonify({'error': 'No file part in request'}), 400

    file = request.files['file']

    if file.filename == '' or not allowed_file(file.filename):
        return jsonify({'error': 'Invalid file'}), 400

    try:
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        # OCR 처리
        ocr_result = ocr_service.process_image(filepath)

        # YOLO 처리
        dmg_tag = predict_damage(filepath)
        yolo_details = predict_damage(filepath, return_details=True)

        # 상세 결과
        response = {
            'result': {
                'title': ocr_result.get('title', ''),
                'author': ocr_result.get('author', ''),
                'publisher': ocr_result.get('publisher', ''),
                'dmg_tag': dmg_tag
            },
            'debug': {
                'ocr_raw': ocr_result.get('raw_ocr', []),
                'yolo_details': yolo_details,
                'file_path': filepath
            }
        }

        return jsonify(response), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    # 서버 실행
    port = int(os.getenv('PORT', 5000))
    debug = os.getenv('DEBUG', 'False').lower() == 'true'

    print(f"""
    ========================================
    OCR & YOLO Integration Server
    ========================================
    Server running on: http://localhost:{port}
    Upload folder: {UPLOAD_FOLDER}
    Debug mode: {debug}
    ========================================
    """)

    app.run(
        host='0.0.0.0',
        port=port,
        debug=debug
    )
