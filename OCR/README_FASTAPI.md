# FastAPI OCR 서비스

Supabase 이미지 URL을 받아 OCR 처리하고 결과를 반환하는 FastAPI 기반 서비스입니다.

## 주요 기능

- **이미지 URL 처리**: Supabase 스토리지의 이미지 URL을 받아 다운로드 및 처리
- **OCR 분석**: EasyOCR을 사용하여 책 제목, 저자, 출판사 추출
- **Supabase 연동**: 처리 결과를 Supabase로 자동 POST (선택사항)

## 설치

### 1. 의존성 설치

```bash
pip install fastapi uvicorn httpx pydantic
```

또는 프로젝트 루트의 requirements.txt 사용:

```bash
cd ..
pip install -r requirements.txt
```

### 2. OCR 모델 확인

`OCR/EasyOCR/user_network/` 디렉터리에 커스텀 모델이 있는지 확인하세요.

## 실행

```bash
cd OCR
python simple_api.py
```

서버가 `http://0.0.0.0:8000`에서 실행됩니다.

## API 문서

서버 실행 후 다음 URL에서 자동 생성된 API 문서를 확인할 수 있습니다:

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## API 엔드포인트

### 1. 헬스 체크

```bash
GET /health
```

**응답:**
```json
{
  "status": "healthy",
  "service": "OCR API"
}
```

### 2. OCR 처리 (Supabase 자동 전송)

```bash
POST /process
Content-Type: application/json

{
  "image_url": "https://your-supabase-project.supabase.co/storage/v1/object/public/books/image.jpg",
  "supabase_callback_url": "https://your-supabase-project.supabase.co/rest/v1/books"
}
```

**응답:**
```json
{
  "title": "책 제목",
  "author": "저자명",
  "publisher": "출판사명"
}
```

**동작 흐름:**
1. `image_url`에서 이미지 다운로드
2. OCR 처리 수행
3. 결과를 API 응답으로 반환
4. `supabase_callback_url`이 제공된 경우 결과를 Supabase로 POST

### 3. OCR 처리 (간단 버전)

```bash
POST /process-simple
Content-Type: application/json

{
  "image_url": "https://example.com/book.jpg"
}
```

**응답:**
```json
{
  "title": "책 제목",
  "author": "저자명",
  "publisher": "출판사명"
}
```

이 엔드포인트는 Supabase로 자동 전송하지 않고 결과만 반환합니다.

## 사용 예제

### cURL

```bash
# 간단 버전
curl -X POST "http://localhost:8000/process-simple" \
  -H "Content-Type: application/json" \
  -d '{
    "image_url": "https://example.com/book.jpg"
  }'

# Supabase 연동
curl -X POST "http://localhost:8000/process" \
  -H "Content-Type: application/json" \
  -d '{
    "image_url": "https://your-project.supabase.co/storage/v1/object/public/books/test.jpg",
    "supabase_callback_url": "https://your-project.supabase.co/rest/v1/books"
  }'
```

### Python

```python
import requests

# OCR 처리
response = requests.post(
    "http://localhost:8000/process-simple",
    json={
        "image_url": "https://example.com/book.jpg"
    }
)

result = response.json()
print(f"Title: {result['title']}")
print(f"Author: {result['author']}")
print(f"Publisher: {result['publisher']}")
```

### JavaScript (Flutter에서 사용)

```javascript
const response = await fetch('http://localhost:8000/process', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    image_url: imageUrl,
    supabase_callback_url: 'https://your-project.supabase.co/rest/v1/books'
  })
});

const result = await response.json();
console.log(result);
```

## Supabase 연동

### 1. Supabase 스토리지 URL 형식

```
https://<project-id>.supabase.co/storage/v1/object/public/<bucket-name>/<file-path>
```

예제:
```
https://abcdefg.supabase.co/storage/v1/object/public/books/uploads/book1.jpg
```

### 2. Supabase REST API URL

```
https://<project-id>.supabase.co/rest/v1/<table-name>
```

예제:
```
https://abcdefg.supabase.co/rest/v1/books
```

### 3. Supabase 인증 (필요한 경우)

Supabase로 데이터를 전송할 때 인증이 필요한 경우, 코드를 수정하여 헤더에 API 키를 추가하세요:

```python
# simple_api.py의 127-132 라인 수정
supabase_response = await client.post(
    request.supabase_callback_url,
    json=result,
    headers={
        "Content-Type": "application/json",
        "apikey": "your-supabase-anon-key",
        "Authorization": f"Bearer your-supabase-anon-key"
    }
)
```

## 환경 설정

### GPU 사용

GPU를 사용하려면 `simple_api.py`의 30번 라인을 수정하세요:

```python
ocr_service = OCRService(
    languages=['ko', 'en'],
    gpu=True,  # False -> True로 변경
    recog_network='custom'
)
```

### 포트 변경

`simple_api.py`의 218번 라인을 수정하세요:

```python
uvicorn.run(app, host='0.0.0.0', port=9000)  # 8000 -> 9000
```

## 트러블슈팅

### 1. FastAPI/Uvicorn 설치 오류

```bash
pip install --upgrade pip
pip install fastapi uvicorn[standard] httpx pydantic
```

### 2. OCR 모델 로딩 실패

- GPU 메모리 부족: `gpu=False`로 설정
- 모델 파일 확인: `OCR/EasyOCR/user_network/` 디렉터리 확인

### 3. 이미지 다운로드 실패

- URL 형식 확인
- 네트워크 연결 확인
- Supabase 스토리지 공개 설정 확인

### 4. Supabase POST 실패

- callback URL 확인
- Supabase 테이블 권한 확인
- 필요시 API 키 추가

## 성능

- 단일 이미지 처리 시간: 약 2-5초 (이미지 다운로드 포함)
- 동시 요청 처리: FastAPI의 비동기 처리로 다중 요청 지원
- 메모리 관리: 임시 파일 자동 삭제

## 개발 모드

개발 시 자동 리로드 활성화:

```bash
uvicorn simple_api:app --reload --host 0.0.0.0 --port 8000
```

## 프로덕션 배포

### Docker (추천)

```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY OCR/ /app/

EXPOSE 8000

CMD ["uvicorn", "simple_api:app", "--host", "0.0.0.0", "--port", "8000"]
```

### systemd 서비스

```ini
[Unit]
Description=OCR FastAPI Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/path/to/Legend_Anabada/OCR
ExecStart=/usr/bin/python3 simple_api.py
Restart=always

[Install]
WantedBy=multi-user.target
```

## 라이선스

Legend Anabada 프로젝트
