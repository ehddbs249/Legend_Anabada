# yolo_predict.py
from ultralytics import YOLO
import json
import os

# YOLO 모델 로드
model_path = os.path.join(os.path.dirname(__file__), "yolov8n.pt")
if not os.path.exists(model_path):
    # best.pt가 있는지 확인
    alt_model_path = os.path.join(os.path.dirname(__file__), "best.pt")
    if os.path.exists(alt_model_path):
        model_path = alt_model_path

try:
    model = YOLO(model_path)
except Exception as e:
    print(f"Warning: Could not load YOLO model from {model_path}: {e}")
    model = None

# 손상 등급 매핑 (클래스 ID -> 손상 등급)
DAMAGE_LEVELS = {
    0: "상",  # 깨끗한 상태
    1: "중상",  # 약간의 손상
    2: "중하",  # 중간 손상
    3: "하",  # 심한 손상
}


DEFAULT_CLASS_NAMES = [
    "class1", "class2", "class3", "class4", "class5",
    "class6", "class7", "class8", "class9"
]


def predict_damage(image_path, return_details=False):
    """
    이미지에서 책 손상 정도를 분석하여 dmg_tag 반환

    Args:
        image_path: 이미지 파일 경로
        return_details: True면 상세 정보 반환, False면 dmg_tag만 반환

    Returns:
        return_details=False: dmg_tag (string) - "상", "중상", "중하", "하"
        return_details=True: dict with detailed information
    """
    if model is None:
        # 모델이 없는 경우 기본값 반환
        if return_details:
            return {
                "dmg_tag": "상",
                "confidence": 0.0,
                "detected_objects": [],
                "error": "YOLO model not loaded"
            }
        return "상"

    if not os.path.exists(image_path):
        if return_details:
            return {
                "dmg_tag": "상",
                "confidence": 0.0,
                "detected_objects": [],
                "error": f"File not found: {image_path}"
            }
        return "상"

    try:
        # YOLO 예측 수행
        results = model.predict(image_path, verbose=False)

        detected_damages = []
        max_damage_level = 0  # 0: 상, 1: 중상, 2: 중하, 3: 하

        for result in results:
            boxes = result.boxes
            if boxes is None or len(boxes) == 0:
                continue

            for box in boxes:
                cls_id = int(box.cls[0])
                confidence = float(box.conf[0])
                x1, y1, x2, y2 = box.xyxy[0].tolist()

                # 클래스 이름 가져오기
                if hasattr(result, 'names') and result.names:
                    cls_name = result.names.get(cls_id, f"class_{cls_id}")
                else:
                    cls_name = DEFAULT_CLASS_NAMES[cls_id] if cls_id < len(DEFAULT_CLASS_NAMES) else f"class_{cls_id}"

                detected_damages.append({
                    "class_id": cls_id,
                    "class_name": cls_name,
                    "confidence": confidence,
                    "bbox": [float(x1), float(y1), float(x2), float(y2)]
                })

                # 손상 등급 결정 (간단한 규칙 기반)
                # 실제 프로젝트에서는 클래스 ID와 손상 등급의 매핑을 조정해야 합니다
                if cls_id >= 7:  # severe damage classes
                    damage_score = 3
                elif cls_id >= 4:  # moderate damage classes
                    damage_score = 2
                elif cls_id >= 1:  # minor damage classes
                    damage_score = 1
                else:  # clean
                    damage_score = 0

                # 최대 손상 등급 갱신
                if damage_score > max_damage_level:
                    max_damage_level = damage_score

        # 손상이 감지되지 않으면 "상" (최상 상태)
        dmg_tag = DAMAGE_LEVELS.get(max_damage_level, "상")

        if return_details:
            return {
                "dmg_tag": dmg_tag,
                "damage_level": max_damage_level,
                "total_detected": len(detected_damages),
                "detected_objects": detected_damages
            }

        return dmg_tag

    except Exception as e:
        print(f"Error in YOLO prediction: {str(e)}")
        if return_details:
            return {
                "dmg_tag": "상",
                "confidence": 0.0,
                "detected_objects": [],
                "error": str(e)
            }
        return "상"


def predict_image(image_path):

    details = predict_damage(image_path, return_details=True)

    output = {
        "dmg_tag": details["dmg_tag"],
        "total_objects": details.get("total_detected", 0),
        "objects": details.get("detected_objects", [])
    }

    return json.dumps(output, ensure_ascii=False, indent=2)


# 테스트용
if __name__ == "__main__":
    import sys

    if len(sys.argv) > 1:
        test_image = sys.argv[1]
    else:
        test_image = "test.jpg"

    print(f"Testing YOLO prediction with: {test_image}")
    print("="*60)

    # 상세 정보 출력
    result_details = predict_damage(test_image, return_details=True)
    print(json.dumps(result_details, ensure_ascii=False, indent=2))

    print("\n" + "="*60)
    print(f"Final dmg_tag: {result_details['dmg_tag']}")
    print("="*60)
