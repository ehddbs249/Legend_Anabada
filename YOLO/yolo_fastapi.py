# app_fastapi.py
import os
import json
import requests
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from yolo_predict import predict_damage  # 기존 yolo_predict.py에서 가져오기
from supabase import create_client, Client

app = FastAPI(title="YOLO Damage Prediction API")

# -------------------------------
# Supabase 초기화
# -------------------------------
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# -------------------------------
# 요청 모델 정의
# -------------------------------
class PredictRequest(BaseModel):
    uuid: str
    image_url: str

# -------------------------------
# 유틸: 이미지 다운로드
# -------------------------------
def download_image(url: str, uuid: str):
    local_path = f"/tmp/{uuid}.jpg"
    try:
        r = requests.get(url)
        r.raise_for_status()
        with open(local_path, "wb") as f:
            f.write(r.content)
        return local_path, None
    except Exception as e:
        return None, str(e)

# -------------------------------
# 예측 + DB 업데이트
# -------------------------------
def process_and_update(uuid: str, image_url: str):
    # 1️⃣ 이미지 다운로드
    local_path, error = download_image(image_url, uuid)
    if error:
        return {"error": f"Failed to download image: {error}"}

    # 2️⃣ YOLO 예측
    result = predict_damage(local_path)

    # 3️⃣ Supabase DB 업데이트
    try:
        supabase.table("book").update({
            "condition_grade": result["damage_level"],
            "dmg_tag": result["damage_tag"]
        }).eq("uuid", uuid).execute()
    except Exception as e:
        result["error"] = f"Failed to update DB: {e}"

    return result

# -------------------------------
# FastAPI 엔드포인트
# -------------------------------
@app.post("/predict")
async def predict(req: PredictRequest):
    if not req.uuid or not req.image_url:
        raise HTTPException(status_code=400, detail="uuid and image_url are required")

    output = process_and_update(req.uuid, req.image_url)
    return output

# -------------------------------
# 실행 방법
# uvicorn app_fastapi:app --reload --host 0.0.0.0 --port 8000
# -------------------------------
