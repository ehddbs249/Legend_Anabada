"""
Simple Flask API for Spring Boot Integration
단순 이미지 업로드 및 OCR 처리
"""
from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from datetime import datetime
from ocr_service import OCRService

app = Flask(__name__)
CORS(app)

# OCR 서비스 초기화
ocr_service = OCRService(
    languages=['ko', 'en'],
    gpu=True,
    recog_network='custom'
)

# 업로드 폴더
UPLOAD_FOLDER = os.path.join(os.path.dirname(__file__), 'uploads')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)


@app.route('/health', methods=['GET'])
def health():
    """Health check"""
    return jsonify({'status': 'ok'})


@app.route('/ocr', methods=['POST'])
def process_ocr():
    """
    단일 이미지 OCR 처리

    Request:
        - file: 이미지 파일 (multipart/form-data)

    Response:
        {
            "success": true,
            "title": "책 제목",
            "author": "저자명",
            "publisher": "출판사명",
            "raw_ocr": [...]
        }
    """
    if 'file' not in request.files:
        return jsonify({
            'success': False,
            'error': 'No file provided'
        }), 400

    file = request.files['file']
    if file.filename == '':
        return jsonify({
            'success': False,
            'error': 'Empty filename'
        }), 400

    try:
        # 파일 저장
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"{timestamp}_{file.filename}"
        filepath = os.path.join(UPLOAD_FOLDER, filename)
        file.save(filepath)

        # OCR 처리
        result = ocr_service.process_image(filepath)

        return jsonify(result), 200

    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500


if __name__ == '__main__':
    print("OCR API Server Starting...")
    print(f"Upload folder: {UPLOAD_FOLDER}")
    print(f"Server: http://0.0.0.0:8000")

    app.run(host='0.0.0.0', port=8000, debug=False)
