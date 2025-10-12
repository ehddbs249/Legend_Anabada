import os
import json
import requests
from ultralytics import YOLO
from supabase import create_client, Client

# -------------------------------
# YOLO 모델 로드
# -------------------------------
def load_yolo_model():
    base_dir = os.path.dirname(__file__)
    model_path = os.path.join(base_dir, "yolov8n.pt")
    if not os.path.exists(model_path):
        alt_path = os.path.join(base_dir, "best.pt")
        if os.path.exists(alt_path):
            model_path = alt_path
    try:
        return YOLO(model_path)
    except Exception as e:
        print(f"⚠️ Warning: Could not load YOLO model from {model_path}: {e}")
        return None

model = load_yolo_model()

# -------------------------------
# 클래스 및 손상 태그 정의
# -------------------------------
FINE_TUNED_CLASS_NAMES = [
    "back_ripped", "back_wear", "front_folded",
    "front_ripped", "front_wear", "side_ripped",
    "side_wear", "stain", "wet"
]

CLASS_TO_TAG = {
    "back_ripped": "ripped", "front_ripped": "ripped", "side_ripped": "ripped",
    "back_wear": "wear", "front_wear": "wear", "side_wear": "wear",
    "front_folded": "folded", "stain": "stain", "wet": "wet"
}

DAMAGE_LEVELS = ["상", "중상", "중", "중하", "하"]

# -------------------------------
# Supabase 초기화
# -------------------------------
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

# -------------------------------
# 손상 예측 함수
# -------------------------------
def predict_damage(image_path):
    if model is None:
        return {"damage_level": "상", "damage_tag": [], "confidence": 0.0, "detected_object_class": [], "detected_object_count": 0, "error": "YOLO model not loaded"}
    if not os.path.exists(image_path):
        return {"damage_level": "상", "damage_tag": [], "confidence": 0.0, "detected_object_class": [], "detected_object_count": 0, "error": f"File not found: {image_path}"}

    try:
        results = model.predict(image_path, verbose=False)
        detected_classes = []
        detected_tags = []
        confidences = []
        max_score = 0

        for result in results:
            boxes = result.boxes
            if not boxes:
                continue
            for box in boxes:
                cls_id = int(box.cls[0])
                conf = float(box.conf[0])
                confidences.append(conf)

                cls_name = FINE_TUNED_CLASS_NAMES[cls_id] if cls_id < len(FINE_TUNED_CLASS_NAMES) else f"class_{cls_id}"
                detected_classes.append(cls_name)

                tag = CLASS_TO_TAG.get(cls_name)
                if tag and tag not in detected_tags:
                    detected_tags.append(tag)

                # 손상 정도 매핑
                if tag == "ripped":
                    score = 3
                elif tag == "wet":
                    score = 4
                elif tag in ["stain", "folded"]:
                    score = 2
                elif tag == "wear":
                    score = 1
                else:
                    score = 0
                max_score = max(max_score, score)

        avg_conf = round(sum(confidences) / len(confidences), 3) if confidences else 0.0
        damage_level = DAMAGE_LEVELS[max_score] if max_score < len(DAMAGE_LEVELS) else "상"

        return {
            "damage_level": damage_level,
            "damage_tag": detected_tags,
            "confidence": avg_conf,
            "detected_object_class": list(set(detected_classes)),
            "detected_object_count": len(detected_classes),
            "error": None
        }

    except Exception as e:
        return {"damage_level": "상", "damage_tag": [], "confidence": 0.0, "detected_object_class": [], "detected_object_count": 0, "error": str(e)}

# -------------------------------
# Supabase에 결과 저장
# -------------------------------
def update_book_condition(uuid: str, image_url: str):
    """
    1. 이미지 다운로드
    2. YOLO 예측
    3. book 테이블 업데이트
    """
    # 임시 파일로 다운로드
    local_path = f"/tmp/{uuid}.jpg"
    try:
        r = requests.get(image_url)
        r.raise_for_status()
        with open(local_path, "wb") as f:
            f.write(r.content)
    except Exception as e:
        return {"error": f"Failed to download image: {e}"}

    # 예측 수행
    result = predict_damage(local_path)

    # DB 업데이트
    try:
        supabase.table("book").update({
            "condition_grade": result["damage_level"],
            "dmg_tag": result["damage_tag"]
        }).eq("uuid", uuid).execute()
    except Exception as e:
        result["error"] = f"Failed to update DB: {e}"

    return result

# -------------------------------
# 테스트 실행
# -------------------------------
if __name__ == "__main__":
    test_uuid = "example-uuid-1234"
    test_image_url = "https://your-supabase-bucket-url/path/to/image.jpg"

    output = update_book_condition(test_uuid, test_image_url)
    print(json.dumps(output, ensure_ascii=False, indent=2))
