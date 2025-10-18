import os
from ultralytics import YOLO

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
    "back_ripped": "찢어짐", "front_ripped": "찢어짐", "side_ripped": "찢어짐",
    "back_wear": "마모", "front_wear": "마모", "side_wear": "마모",
    "front_folded": "접힘", "stain": "얼룩", "wet": "젖음"
}

# 손상 단계 4단계
DAMAGE_LEVELS = ["최상", "양호", "보통", "하급"]

# -------------------------------
# 손상 예측 함수
# -------------------------------
def predict_damage(image_path):
    if model is None:
        return {
            "damage_level": "상",
            "damage_tag": [],
            "confidence": 0.0,
            "detected_object_class": [],
            "detected_object_count": 0,
            "error": "YOLO model not loaded"
        }

    if not os.path.exists(image_path):
        return {
            "damage_level": "상",
            "damage_tag": [],
            "confidence": 0.0,
            "detected_object_class": [],
            "detected_object_count": 0,
            "error": f"File not found: {image_path}"
        }

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

                cls_name = (
                    FINE_TUNED_CLASS_NAMES[cls_id]
                    if cls_id < len(FINE_TUNED_CLASS_NAMES)
                    else f"class_{cls_id}"
                )
                detected_classes.append(cls_name)

                tag = CLASS_TO_TAG.get(cls_name)
                if tag and tag not in detected_tags:
                    detected_tags.append(tag)

                # 손상 정도 점수 (4단계)
                if tag in ["ripped", "wet"]:
                    score = 3   # 최하
                elif tag in ["stain", "folded"]:
                    score = 2   # 하
                elif tag == "wear":
                    score = 1   # 중
                else:
                    score = 0   # 상
                max_score = max(max_score, score)

        avg_conf = round(sum(confidences) / len(confidences), 3) if confidences else 0.0
        damage_level = DAMAGE_LEVELS[min(max_score, 3)]

        return {
            "damage_level": damage_level,
            "damage_tag": detected_tags,
            "confidence": avg_conf,
            "detected_object_class": list(set(detected_classes)),
            "detected_object_count": len(detected_classes),
            "error": None
        }

    except Exception as e:
        return {
            "damage_level": "상",
            "damage_tag": [],
            "confidence": 0.0,
            "detected_object_class": [],
            "detected_object_count": 0,
            "error": str(e)
        }
