"""
FastAPI OCR Service
Supabase 이미지 URL을 받아 OCR 처리 후 결과를 Supabase로 전송
"""
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
from datetime import datetime
from ocr_service import OCRService
import httpx
from supabase import create_client, Client
from dotenv import load_dotenv

# 환경 변수 로드
load_dotenv()

app = FastAPI(title="OCR Service API", version="1.0.0")

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Supabase 클라이언트 초기화
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

supabase_client: Client | None = None
if SUPABASE_URL and SUPABASE_KEY:
    try:
        supabase_client = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✓ Supabase client initialized")
    except Exception as e:
        print(f"✗ Failed to initialize Supabase client: {e}")
else:
    print("⚠ Supabase credentials not found. Set SUPABASE_URL and SUPABASE_KEY in .env file")

# OCR 서비스 초기화
print("Initializing OCR Service...")
ocr_service = OCRService(
    languages=['ko', 'en'],
    gpu=False,  # GPU 사용 여부 (환경에 맞게 설정)
    recog_network='custom'
)
print("✓ OCR Service initialized")

# 임시 폴더
TEMP_FOLDER = os.path.join(os.path.dirname(__file__), 'temp')
os.makedirs(TEMP_FOLDER, exist_ok=True)


# 요청 모델
class ImageRequest(BaseModel):
    image_url: str
    book_id: str | None = None  # Supabase에서 업데이트할 책 ID
    table_name: str = "books"  # Supabase 테이블 이름

    class Config:
        json_schema_extra = {
            "example": {
                "image_url": "https://your-project.supabase.co/storage/v1/object/public/books/image.jpg",
                "book_id": "123e4567-e89b-12d3-a456-426614174000",
                "table_name": "books"
            }
        }


# 응답 모델
class OCRResponse(BaseModel):
    title: str
    author: str
    publisher: str


@app.get("/health")
async def health_check():
    """헬스 체크"""
    return {"status": "healthy", "service": "OCR API"}


@app.post("/process", response_model=OCRResponse)
async def process_ocr(request: ImageRequest):
    """
    Supabase 이미지 URL로부터 OCR 처리 후 Supabase에 저장

    Request Body:
        {
            "image_url": "https://...",
            "book_id": "uuid" (optional),
            "table_name": "books" (default)
        }

    Response:
        {
            "title": "책 제목",
            "author": "저자명",
            "publisher": "출판사명"
        }
    """
    if not supabase_client:
        raise HTTPException(
            status_code=500,
            detail="Supabase client not initialized. Check SUPABASE_URL and SUPABASE_KEY"
        )

    temp_filepath = None

    try:
        # 1. 이미지 URL에서 다운로드
        print(f"📥 Downloading image from: {request.image_url}")

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(request.image_url)
            response.raise_for_status()

        # 2. 임시 파일로 저장
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        temp_filepath = os.path.join(TEMP_FOLDER, f"{timestamp}.jpg")

        with open(temp_filepath, 'wb') as f:
            f.write(response.content)

        print(f"💾 Image saved to: {temp_filepath}")

        # 3. OCR 처리
        print("🔍 Processing OCR...")
        ocr_result = ocr_service.process_image(temp_filepath)

        if not ocr_result.get('success', False):
            raise HTTPException(
                status_code=500,
                detail=f"OCR processing failed: {ocr_result.get('error', 'Unknown error')}"
            )

        # 4. 결과 준비
        result = {
            "title": ocr_result.get('title', ''),
            "author": ocr_result.get('author', ''),
            "publisher": ocr_result.get('publisher', '')
        }

        print(f"✓ OCR Result: {result}")

        # 5. Supabase에 저장
        try:
            if request.book_id:
                # book_id가 있으면 업데이트
                print(f"📤 Updating Supabase record: {request.book_id}")
                response = supabase_client.table(request.table_name).update(result).eq("id", request.book_id).execute()
                print(f"✓ Successfully updated book {request.book_id}")
            else:
                # book_id가 없으면 새로 생성
                print(f"📤 Inserting new record to Supabase")
                response = supabase_client.table(request.table_name).insert(result).execute()
                print(f"✓ Successfully inserted new book")
        except Exception as e:
            print(f"⚠ Warning: Failed to save to Supabase: {str(e)}")
            # Supabase 저장 실패해도 OCR 결과는 반환

        return result

    except httpx.HTTPStatusError as e:
        raise HTTPException(
            status_code=400,
            detail=f"Failed to download image: {str(e)}"
        )
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(
            status_code=500,
            detail=f"Internal server error: {str(e)}"
        )
    finally:
        # 임시 파일 삭제
        if temp_filepath and os.path.exists(temp_filepath):
            try:
                os.remove(temp_filepath)
                print(f"🗑️ Cleaned up temp file: {temp_filepath}")
            except Exception as e:
                print(f"⚠ Warning: Could not delete temp file: {e}")


@app.post("/process-simple")
async def process_ocr_simple(request: ImageRequest):
    """
    간단한 버전 - URL만 받아서 OCR 처리 후 결과 반환
    Supabase로 자동 전송하지 않음
    """
    temp_filepath = None

    try:
        # 이미지 다운로드
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(request.image_url)
            response.raise_for_status()

        # 임시 파일 저장
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        temp_filepath = os.path.join(TEMP_FOLDER, f"{timestamp}.jpg")

        with open(temp_filepath, 'wb') as f:
            f.write(response.content)

        # OCR 처리
        ocr_result = ocr_service.process_image(temp_filepath)

        if not ocr_result.get('success', False):
            raise HTTPException(status_code=500, detail="OCR processing failed")

        return {
            "title": ocr_result.get('title', ''),
            "author": ocr_result.get('author', ''),
            "publisher": ocr_result.get('publisher', '')
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    finally:
        if temp_filepath and os.path.exists(temp_filepath):
            try:
                os.remove(temp_filepath)
            except:
                pass


if __name__ == '__main__':
    import uvicorn

    print("="*60)
    print("OCR FastAPI Server")
    print("="*60)
    print(f"Temp folder: {TEMP_FOLDER}")
    print(f"Server: http://0.0.0.0:8000")
    print(f"Docs: http://0.0.0.0:8000/docs")
    print("="*60)

    uvicorn.run(app, host='0.0.0.0', port=8000)
