"""
Standalone OCR Script
CLI에서 직접 실행 가능한 독립 스크립트
Spring Boot에서 ProcessBuilder로 호출 가능

Usage:
    python standalone_ocr.py <image_path>

Output:
    JSON format to stdout
"""
import sys
import os

# 프로젝트 루트 경로 설정
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(CURRENT_DIR)

# ocr_service 모듈 import
sys.path.insert(0, CURRENT_DIR)
from ocr_service import OCRService
import json


def main():
    if len(sys.argv) < 2:
        print(json.dumps({
            'success': False,
            'error': 'Usage: python standalone_ocr.py <image_path>'
        }), file=sys.stderr)
        sys.exit(1)

    image_path = sys.argv[1]

    try:
        # OCR 서비스 초기화
        service = OCRService(
            languages=['ko', 'en'],
            gpu=True,
            recog_network='custom'
        )

        # 이미지 처리
        result = service.process_image(image_path)

        # JSON 출력 (stdout)
        print(json.dumps(result, ensure_ascii=False))

    except Exception as e:
        print(json.dumps({
            'success': False,
            'error': str(e)
        }), file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
