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
        min_confidence=0.5,
        use_bbox_size=True,
        title_size_threshold=0.65,  # 큰 텍스트 기준 (0.7~1.0)
        medium_size_threshold=0.31,  # 중간 크기 하한선 (0.31~0.69)
        author_size_threshold=0.3,  # 작은 텍스트 상한선 (0~0.3)
        proximity_threshold=100,  # 키워드 근처 거리 기준 (픽셀)
        publisher_y_threshold=0.7,  # 출판사 Y축 하단 기준 (0.7~1.0)
        publisher_x_left_threshold=0.3,  # 출판사 왼쪽 기준 (0~0.3)
        publisher_x_right_threshold=0.7  # 출판사 오른쪽 기준 (0.7~1.0)
    ):
        self.min_confidence = min_confidence

        # bbox 크기 기반 분류 설정
        self.use_bbox_size = use_bbox_size
        self.title_size_threshold = title_size_threshold
        self.medium_size_threshold = medium_size_threshold
        self.author_size_threshold = author_size_threshold
        self.proximity_threshold = proximity_threshold

        # 출판사 위치 기준
        self.publisher_y_threshold = publisher_y_threshold
        self.publisher_x_left_threshold = publisher_x_left_threshold
        self.publisher_x_right_threshold = publisher_x_right_threshold

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

        # X축 정규화 (출판사 위치 판단용)
        min_x = min(r['center_x'] for r in filtered_results)
        max_x = max(r['center_x'] for r in filtered_results)
        x_range = max_x - min_x if max_x > min_x else 1

        for result in filtered_results:
            result['normalized_x'] = (result['center_x'] - min_x) / x_range

        # bbox 크기 계산 및 0-1 정규화
        if self.use_bbox_size:
            for result in filtered_results:
                result['bbox_size'] = self._calculate_bbox_size(result['bbox'])

            # 최소/최대 bbox 크기 계산
            min_size = min(r['bbox_size'] for r in filtered_results)
            max_size = max(r['bbox_size'] for r in filtered_results)
            size_range = max_size - min_size if max_size > min_size else 1.0

            # 0-1로 정규화
            for result in filtered_results:
                result['bbox_size_ratio'] = (result['bbox_size'] - min_size) / size_range if size_range > 0 else 0.5

        # Y축 기준 정렬
        sorted_results = sorted(filtered_results, key=lambda x: x['normalized_y'])

        # 1단계: 키워드가 있는 텍스트 찾기
        keyword_results = {
            'author': [],
            'publisher': []
        }

        for result in sorted_results:
            text = result['text']
            text_lower = text.lower()

            # 키워드 찾기
            if any(keyword in text for keyword in self.author_keywords):
                keyword_results['author'].append(result)
                result['has_keyword'] = True
                result['keyword_type'] = 'author'
            elif any(keyword in text_lower for keyword in self.publisher_keywords):
                keyword_results['publisher'].append(result)
                result['has_keyword'] = True
                result['keyword_type'] = 'publisher'
            else:
                result['has_keyword'] = False

        # 2단계: bbox 크기 분류 (0-1 정규화 기준)
        for result in sorted_results:
            size_ratio = result.get('bbox_size_ratio', 0.5)

            # 큰 텍스트 (0.7~1.0) - 무조건 제목
            if size_ratio >= self.title_size_threshold:
                result['size_category'] = 'large'
            # 중간 크기 (0.31~0.69) - 제외
            elif size_ratio >= self.medium_size_threshold:
                result['size_category'] = 'medium'
            # 작은 텍스트 (0~0.3) - 저자
            else:
                result['size_category'] = 'small'

        # 3단계: 키워드 우선 분류
        title_texts = []
        author_texts = []
        publisher_texts = []
        has_author_keyword = False

        # 먼저 키워드가 있는지 확인
        for result in sorted_results:
            if result.get('keyword_type') == 'author':
                has_author_keyword = True
                break

        for result in sorted_results:
            # 중간 크기는 제외
            if result.get('size_category') == 'medium':
                result['classification'] = 'excluded'
                continue

            # 큰 텍스트는 무조건 제목
            if result.get('size_category') == 'large':
                result['classification'] = 'title'
                title_texts.append(result)
                continue

            # 키워드가 있는 텍스트 처리
            if result.get('has_keyword'):
                keyword_type = result.get('keyword_type')
                if keyword_type == 'author':
                    result['classification'] = 'author'
                    author_texts.append(result)

                    # 근처 텍스트 찾기
                    nearby = self._find_nearby_texts(result, sorted_results)
                    for nearby_text in nearby:
                        if not nearby_text.get('classification'):
                            nearby_text['classification'] = 'author'
                            author_texts.append(nearby_text)

                elif keyword_type == 'publisher':
                    # 키워드가 있으면 무조건 출판사
                    result['classification'] = 'publisher'
                    publisher_texts.append(result)

                    # 근처 텍스트 찾기
                    nearby = self._find_nearby_texts(result, sorted_results)
                    for nearby_text in nearby:
                        if not nearby_text.get('classification'):
                            nearby_text['classification'] = 'publisher'
                            publisher_texts.append(nearby_text)

            # 출판사 위치 판단 (키워드 없어도 위치로 분류)
            elif self._is_publisher_position(result):
                if not result.get('classification'):
                    result['classification'] = 'publisher'
                    publisher_texts.append(result)

            # 작은 텍스트 처리
            elif result.get('size_category') == 'small':
                # 저자 키워드가 있으면 작은 텍스트는 제외
                if has_author_keyword:
                    result['classification'] = 'excluded'
                # 저자 키워드가 없으면 작은 텍스트는 저자로
                else:
                    result['classification'] = 'author'
                    author_texts.append(result)

        # 텍스트 병합
        title = self._merge_texts(title_texts, sort_by='position')  # Y축 위치 순서
        author = self._merge_texts(author_texts, sort_by='confidence')  # 신뢰도 순서
        publisher = self._merge_texts(publisher_texts, sort_by='confidence')  # 신뢰도 순서

        # 정제
        author = self._clean_author_text(author)
        publisher = self._clean_publisher_text(publisher)

        return {
            'title': title,
            'author': author,
            'publisher': publisher,
            'all_texts': sorted_results
        }

    def _is_publisher_position(self, result):
        """
        출판사 위치인지 판단 (오른쪽 아래 또는 왼쪽 아래)

        Args:
            result: 텍스트 결과

        Returns:
            bool: 출판사 위치이면 True
        """
        norm_y = result.get('normalized_y', 0)
        norm_x = result.get('normalized_x', 0.5)

        # Y축: 하단 (0.7~1.0)
        is_bottom = norm_y >= self.publisher_y_threshold

        # X축: 왼쪽 (0~0.3) 또는 오른쪽 (0.7~1.0)
        is_left = norm_x <= self.publisher_x_left_threshold
        is_right = norm_x >= self.publisher_x_right_threshold

        # 하단이면서 좌측 또는 우측
        return is_bottom and (is_left or is_right)

    def _find_nearby_texts(self, keyword_result, all_results):
        """
        키워드가 있는 텍스트 근처의 다른 텍스트들을 찾음

        Args:
            keyword_result: 키워드가 포함된 텍스트 결과
            all_results: 모든 텍스트 결과 리스트

        Returns:
            list: 근처에 있는 텍스트들
        """
        nearby_texts = []
        keyword_center_x = keyword_result['center_x']
        keyword_center_y = keyword_result['center_y']

        for result in all_results:
            # 자기 자신은 제외
            if result is keyword_result:
                continue

            # 이미 분류된 것은 제외
            if result.get('classification'):
                continue

            # 중간 크기는 제외
            if result.get('size_category') == 'medium':
                continue

            # 큰 텍스트는 제외 (제목이므로)
            if result.get('size_category') == 'large':
                continue

            # 거리 계산
            distance_x = abs(result['center_x'] - keyword_center_x)
            distance_y = abs(result['center_y'] - keyword_center_y)
            distance = (distance_x ** 2 + distance_y ** 2) ** 0.5

            # 근처에 있으면 추가
            if distance <= self.proximity_threshold:
                nearby_texts.append(result)

        return nearby_texts

    def _calculate_bbox_size(self, bbox):
        """
        bbox의 크기(면적) 계산

        Args:
            bbox: [[x1,y1], [x2,y2], [x3,y3], [x4,y4]] 형식의 좌표

        Returns:
            float: bbox의 면적
        """
        # bbox에서 너비와 높이 계산
        x_coords = [point[0] for point in bbox]
        y_coords = [point[1] for point in bbox]

        width = max(x_coords) - min(x_coords)
        height = max(y_coords) - min(y_coords)

        return width * height

    def _merge_texts(self, text_list, sort_by='confidence'):
        """
        텍스트 리스트를 병합

        Args:
            text_list: 텍스트 결과 리스트
            sort_by: 정렬 기준 ('confidence', 'position')

        Returns:
            str: 병합된 텍스트
        """
        if not text_list:
            return ''

        # 정렬 기준에 따라 정렬
        if sort_by == 'position':
            # Y축 위치 순서로 정렬 (위에서 아래로)
            sorted_texts = sorted(text_list, key=lambda x: x.get('center_y', 0))
        else:
            # 신뢰도 순서로 정렬 (높은 것부터)
            sorted_texts = sorted(text_list, key=lambda x: x.get('confidence', 0), reverse=True)

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
