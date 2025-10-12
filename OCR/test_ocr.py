"""
OCR Service Test Script
"""
import sys
import os

# 현재 디렉터리를 sys.path에 추가
sys.path.insert(0, os.path.dirname(__file__))

from ocr_service import OCRService
import json


def test_local_image():
    """로컬 이미지 테스트"""
    # 테스트 이미지 경로
    test_image_dir = os.path.join(
        os.path.dirname(__file__),
        'EasyOCR', 'demoimg'
    )

    if not os.path.exists(test_image_dir):
        print(f"Test image directory not found: {test_image_dir}")
        return

    # 이미지 파일 찾기
    image_files = [
        os.path.join(test_image_dir, f)
        for f in os.listdir(test_image_dir)
        if f.lower().endswith(('.jpg', '.jpeg', '.png'))
    ]

    if not image_files:
        print(f"No test images found in: {test_image_dir}")
        return

    print(f"Testing with: {image_files[0]}\n")

    # OCR 서비스 초기화
    service = OCRService(
        languages=['ko', 'en'],
        gpu=True,
        recog_network='custom'
    )

    # 이미지 처리
    result = service.process_image(image_files[0])

    # 결과 출력
    print(json.dumps(result, ensure_ascii=False, indent=2))

    if result['success']:
        print("\n" + "="*60)
        print("OCR Result Summary")
        print("="*60)
        print(f"Title:     {result['title']}")
        print(f"Author:    {result['author']}")
        print(f"Publisher: {result['publisher']}")
        print(f"Detected:  {len(result['raw_ocr'])} text regions")
        print("="*60)


if __name__ == '__main__':
    if len(sys.argv) > 1:
        # CLI 인자로 이미지 경로 지정
        image_path = sys.argv[1]
        service = OCRService()
        result = service.process_image(image_path)
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        # 테스트 이미지로 실행
        test_local_image()
