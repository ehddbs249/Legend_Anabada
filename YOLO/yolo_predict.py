# yolo_predict.py
from ultralytics import YOLO
import json

# YOLO 모델 로드 (yolov8n.pt 등)
model = YOLO("yolov8n.pt")  

# 클래스 이름 설정 (총 9개)
CLASS_NAMES = [
    "class1", "class2", "class3", "class4", "class5",
    "class6", "class7", "class8", "class9"
]

def predict_image(image_path):
    """
    이미지 경로를 입력받아 YOLO로 예측 후 JSON 형태로 반환
    """
    results = model.predict(image_path)
    
    output = {
        "total_objects": 0,
        "class_counts": {cls: 0 for cls in CLASS_NAMES},
        "objects": []
    }

    for result in results:  # 결과가 여러 이미지일 경우를 대비
        boxes = result.boxes
        for i, box in enumerate(boxes):
            cls_id = int(box.cls[0])
            cls_name = CLASS_NAMES[cls_id]
            x1, y1, x2, y2 = box.xyxy[0].tolist()
            width = x2 - x1
            height = y2 - y1

            output["objects"].append({
                "class": cls_name,
                "bbox": [x1, y1, x2, y2],
                "width": width,
                "height": height
            })
            output["class_counts"][cls_name] += 1
            output["total_objects"] += 1

    return json.dumps(output, ensure_ascii=False, indent=2)

# 테스트용
if __name__ == "__main__":
    result_json = predict_image("test.jpg")
    print(result_json)
