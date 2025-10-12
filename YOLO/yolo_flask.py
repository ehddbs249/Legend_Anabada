# app.py
import os
import json
import requests
from flask import Flask, request, jsonify
from yolo_predict import predict_damage  # 기존 yolo_predict.py에서 predict_damage 사용
from supabase import create_client, Client

app = Flask(__name__)

# -------------------------------
# Supabase 초기화
# -------------------------------
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# -------------------------------
# 유틸 함수: 이미지 다운로드
# -------------------------------
def download_image(url, uuid):
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
def process_and_update(uuid, image_url):
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
# Flask API 엔드포인트
# -------------------------------
@app.route("/predict", methods=["POST"])
def predict():
    data = request.get_json()
    uuid = data.get("uuid")
    image_url = data.get("image_url")

    if not uuid or not image_url:
        return jsonify({"error": "uuid and image_url are required"}), 400

    output = process_and_update(uuid, image_url)
    return jsonify(output)

# -------------------------------
# Flask 실행
# -------------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
