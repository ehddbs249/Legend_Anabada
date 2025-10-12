"""
FastAPI OCR + YOLO Damage Prediction Service
Supabase 이미지 URL을 받아 OCR + YOLO 처리 후 book 테이블 업데이트
"""
import os
import json
import requests
from datetime import datetime
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from yolo_predict import predict_damage  # YOLO 손상 예측
from ocr_service import OCRService      # OCR 서비스
from supabase import create_client, Client
from dotenv import load_dotenv

# -------------------------------
# 환경 변수 로드
# -------------------------------
load_dotenv()
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

# -------------------------------
# FastAPI 초기화
# -------------------------------
app = FastAPI(title="OCR + YOLO API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------------------
# 임시 폴더
# -------------------------------
TEMP_FOLDER = os.path.join(os.path.dirname(__file__), 'temp')
os.makedirs(TEMP_FOLDER, exist_ok=True)

# -------------------------------
# OCR 서비스 초기화
# -------------------------------
ocr_service = OCRService(languages=['ko', 'en'], gpu=False)

# -------------------------------
# 요청 모델
# -------------------------------
class PredictRequest(BaseModel):
    uuid: str
    image_url: str
    table_name: str = "book"

# -------------------------------
# 헬스체크
# -------------------------------
@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "OCR + YOLO API"}

# -------------------------------
# 이미지 다운로드
# -------------------------------
def download_image(url: str, uuid: str):
    local_path = os.path.join(TEMP_FOLDER, f"{uuid}.jpg")
    try:
        r = requests.get(url, timeout=30)
        r.raise_for_status()
        with open(local_path, "wb") as f:
            f.write(r.content)
        return local_path, None
    except Exception as e:
        return None, str(e)

# -------------------------------
# 처리 + DB 업데이트
# -------------------------------
def process_image(uuid: str, image_url: str, table_name: str):
    # 1️⃣ 이미지 다운로드
    local_path, error = download_image(image_url, uuid)
    if error:
        return {"error": f"Failed to download image: {error}"}

    # 2️⃣ OCR 처리
    ocr_result = ocr_service.process_image(local_path)
    title = ocr_result.get("title", "")
    author = ocr_result.get("author", "")
    publisher = ocr_result.get("publisher", "")

    # 3️⃣ YOLO 손상 예측
    yolo_result = predict_damage(local_path)

    # 4️⃣ Supabase DB 업데이트
    update_data = {
        "title": title,
        "author": author,
        "publisher": publisher,
        "condition_grade": yolo_result.get("damage_level", "상"),
        "dmg_tag": yolo_result.get("damage_tag", [])
    }

    try:
        supabase_client.table(table_name).update(update_data).eq("uuid", uuid).execute()
    except Exception as e:
        update_data["error"] = f"Failed to update DB: {e}"

    return {**update_data, "ocr_raw": ocr_result.get("raw_ocr", []), "yolo_raw": yolo_result}

# -------------------------------
# FastAPI 엔드포인트
# -------------------------------
@app.post("/predict")
async def predict(req: PredictRequest):
    if not supabase_client:
        raise HTTPException(
            status_code=500,
            detail="Supabase client not initialized. Check SUPABASE_URL and SUPABASE_KEY"
        )
    if not req.uuid or not req.image_url:
        raise HTTPException(status_code=400, detail="uuid and image_url are required")

    output = process_image(req.uuid, req.image_url, req.table_name)
    return output

# -------------------------------
# 실행
# -------------------------------
if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host='0.0.0.0', port=8000, reload=True)
