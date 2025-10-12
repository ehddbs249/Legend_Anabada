"""
EasyOCR Service - Spring Boot Integration
단일 이미지 OCR 처리 및 분류 모듈
"""
import os
import sys
import json
from pathlib import Path

# 프로젝트 루트 경로 설정
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(CURRENT_DIR)
EASYOCR_PATH = os.path.join(CURRENT_DIR, 'EasyOCR')

# EasyOCR 경로 추가
if EASYOCR_PATH not in sys.path:
    sys.path.insert(0, EASYOCR_PATH)

from easyocr.easyocr import Reader
import re


class TextClassifier:
    """텍스트 위치 기반 분류"""

    def __init__(
        self,
        title_region=(0, 0.4),
        author_region=(0.4, 0.7),
        publisher_region=(0.7, 1.0),
        min_confidence=0.5
    ):
        self.title_region = title_region
        self.author_region = author_region
        self.publisher_region = publisher_region
        self.min_confidence = min_confidence

        self.author_keywords = [
            '저자', '지은이', '글쓴이', '작가', '지음', '글',
            '저', '역자', '옮긴이', '편저', '편역'
        ]
        self.publisher_keywords = [
            '출판', '출판사', '발행', '인쇄', '사',
            '북', 'book', 'press', 'publishing'
        ]

    def classify(self, ocr_results):
        if not ocr_results:
            return {
                'title': '',
                'author': '',
                'publisher': '',
                'all_texts': []
            }

        # 신뢰도 필터링
        filtered_results = [
            r for r in ocr_results
            if r['confidence'] >= self.min_confidence
        ]

        if not filtered_results:
            return {
                'title': '',
                'author': '',
                'publisher': '',
                'all_texts': []
            }

        # Y축 정규화
        min_y = min(r['center_y'] for r in filtered_results)
        max_y = max(r['center_y'] for r in filtered_results)
        y_range = max_y - min_y if max_y > min_y else 1

        for result in filtered_results:
            result['normalized_y'] = (result['center_y'] - min_y) / y_range

        # Y축 기준 정렬
        sorted_results = sorted(filtered_results, key=lambda x: x['normalized_y'])

        # 분류
        title_texts = []
        author_texts = []
        publisher_texts = []

        for result in sorted_results:
            norm_y = result['normalized_y']
            text = result['text']
            text_lower = text.lower()

            # 키워드 기반 분류
            if any(keyword in text for keyword in self.author_keywords):
                classification = 'author'
                author_texts.append(result)
            elif any(keyword in text_lower for keyword in self.publisher_keywords):
                classification = 'publisher'
                publisher_texts.append(result)
            # 위치 기반 분류
            elif self.title_region[0] <= norm_y < self.title_region[1]:
                classification = 'title'
                title_texts.append(result)
            elif self.author_region[0] <= norm_y < self.author_region[1]:
                classification = 'author'
                author_texts.append(result)
            elif self.publisher_region[0] <= norm_y <= self.publisher_region[1]:
                classification = 'publisher'
                publisher_texts.append(result)
            else:
                classification = 'title'
                title_texts.append(result)

            result['classification'] = classification

        # 텍스트 병합
        title = self._merge_texts(title_texts)
        author = self._merge_texts(author_texts)
        publisher = self._merge_texts(publisher_texts)

        # 정제
        author = self._clean_author_text(author)
        publisher = self._clean_publisher_text(publisher)

        return {
            'title': title,
            'author': author,
            'publisher': publisher,
            'all_texts': sorted_results
        }

    def _merge_texts(self, text_list):
        if not text_list:
            return ''
        sorted_texts = sorted(text_list, key=lambda x: x['confidence'], reverse=True)
        merged = ' '.join([t['text'] for t in sorted_texts])
        return merged.strip()

    def _clean_author_text(self, text):
        if not text:
            return ''
        patterns = [
            r'저자\s*[:\-]?\s*',
            r'지은이\s*[:\-]?\s*',
            r'글쓴이\s*[:\-]?\s*',
            r'작가\s*[:\-]?\s*',
            r'지음\s*[:\-]?\s*',
            r'글\s*[:\-]?\s*',
            r'저\s*[:\-]?\s*',
            r'역자\s*[:\-]?\s*',
            r'옮긴이\s*[:\-]?\s*',
        ]
        cleaned = text
        for pattern in patterns:
            cleaned = re.sub(pattern, '', cleaned)
        return cleaned.strip()

    def _clean_publisher_text(self, text):
        if not text:
            return ''
        patterns = [
            r'출판사\s*[:\-]?\s*',
            r'발행\s*[:\-]?\s*',
            r'인쇄\s*[:\-]?\s*',
        ]
        cleaned = text
        for pattern in patterns:
            cleaned = re.sub(pattern, '', cleaned)
        return cleaned.strip()


class OCRService:
    """EasyOCR 서비스"""

    def __init__(
        self,
        languages=['ko', 'en'],
        gpu=True,
        model_storage_directory=None,
        user_network_directory=None,
        recog_network='custom'
    ):
        # GPU 설정
        if gpu:
            os.environ['CUDA_VISIBLE_DEVICES'] = '0'

        # 기본 경로 설정
        if model_storage_directory is None:
            model_storage_directory = os.path.join(EASYOCR_PATH, 'user_network')
        if user_network_directory is None:
            user_network_directory = os.path.join(EASYOCR_PATH, 'user_network')

        self.model_storage_directory = model_storage_directory
        self.user_network_directory = user_network_directory

        # Reader 초기화
        self.reader = Reader(
            languages,
            gpu=gpu,
            model_storage_directory=model_storage_directory,
            user_network_directory=user_network_directory,
            recog_network=recog_network
        )

        # 분류기 초기화
        self.classifier = TextClassifier()

    def process_image(self, image_path):
        """
        단일 이미지 처리

        Args:
            image_path: 이미지 파일 경로

        Returns:
            dict: {
                'success': bool,
                'title': str,
                'author': str,
                'publisher': str,
                'raw_ocr': [...]
            }
        """
        if not os.path.exists(image_path):
            return {
                'success': False,
                'error': f'File not found: {image_path}'
            }

        try:
            # OCR 수행
            raw_results = self.reader.readtext(image_path)

            # 결과 포맷팅
            ocr_results = []
            for bbox, text, confidence in raw_results:
                center_x = sum([point[0] for point in bbox]) / 4
                center_y = sum([point[1] for point in bbox]) / 4

                ocr_results.append({
                    'bbox': bbox,
                    'text': text,
                    'confidence': float(confidence),
                    'center_x': center_x,
                    'center_y': center_y
                })

            # 텍스트 분류
            classified = self.classifier.classify(ocr_results)

            # 응답 구성 (numpy 타입을 Python 기본 타입으로 변환)
            result = {
                'success': True,
                'title': classified['title'],
                'author': classified['author'],
                'publisher': classified['publisher'],
                'raw_ocr': [
                    {
                        'text': item['text'],
                        'bbox': [[float(x), float(y)] for x, y in item['bbox']],
                        'confidence': float(item['confidence']),
                        'classification': item['classification'],
                        'position': {
                            'center_x': float(item['center_x']),
                            'center_y': float(item['center_y'])
                        }
                    }
                    for item in classified['all_texts']
                ]
            }

            return result

        except Exception as e:
            return {
                'success': False,
                'error': str(e)
            }


def main():
    """
    CLI 실행 인터페이스
    Usage: python ocr_service.py <image_path>
    """
    if len(sys.argv) < 2:
        print(json.dumps({
            'success': False,
            'error': 'Usage: python ocr_service.py <image_path>'
        }))
        sys.exit(1)

    image_path = sys.argv[1]

    # 환경 변수에서 설정 로드 (옵션)
    gpu = os.getenv('OCR_GPU', 'true').lower() == 'true'
    model_dir = os.getenv('MODEL_STORAGE_DIR')
    user_dir = os.getenv('USER_NETWORK_DIR')

    # OCR 서비스 초기화
    service = OCRService(
        languages=['ko', 'en'],
        gpu=gpu,
        model_storage_directory=model_dir,
        user_network_directory=user_dir,
        recog_network='custom'
    )

    # 이미지 처리
    result = service.process_image(image_path)

    # JSON 출력
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == '__main__':
    main()
