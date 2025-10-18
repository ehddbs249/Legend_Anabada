"""
FastAPI OCR + YOLO Damage Prediction Service
이미지 파일(multipart/form-data) 업로드 후 OCR + YOLO 결과 반환
"""
import os
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"
import shutil
import uuid
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from yolo_predict import predict_damage  # YOLO 손상 예측 함수
from ocr_service import OCRService       # OCR 서비스

# -------------------------------
# FastAPI 초기화
# -------------------------------
app = FastAPI(title="OCR + YOLO API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 필요 시 도메인 제한 가능
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------------------
# 임시 폴더 설정
# -------------------------------
TEMP_FOLDER = os.path.join(os.path.dirname(__file__), "temp")
os.makedirs(TEMP_FOLDER, exist_ok=True)

# -------------------------------
# OCR 서비스 초기화
# -------------------------------
ocr_service = OCRService(languages=["ko", "en"], gpu=False)

# -------------------------------
# 엔드포인트
# -------------------------------
@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    print("1번 과정 파일 저장 시작")
    # 1️⃣ 파일 저장
    try:
        file_ext = os.path.splitext(file.filename)[1].lower()
        file_id = str(uuid.uuid4())
        local_path = os.path.join(TEMP_FOLDER, f"{file_id}{file_ext}")
        with open(local_path, "wb") as f:
            shutil.copyfileobj(file.file, f)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"파일 저장 실패: {e}")
    print("1번 과정 파일 저장 끝")

    print("2번 과정 OCR 처리 시작")
    # 2️⃣ OCR 처리
    try:
        ocr_result = ocr_service.process_image(local_path)
        title = ocr_result.get("title", "")
        author = ocr_result.get("author", "")
        publisher = ocr_result.get("publisher", "")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OCR 처리 실패: {e}")
    print({
        "title": title,
        "author": author,
        "publisher": publisher
    })
    print("2번 과정 OCR 처리 끝")

    print("3번 과정 YOLO 손상 예측 시작")
    # 3️⃣ YOLO 손상 예측
    try:
        yolo_result = predict_damage(local_path)
        condition_grade = yolo_result.get("damage_level", "상")
        dmg_tag = yolo_result.get("damage_tag", [])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"YOLO 예측 실패: {e}")
    print({
        "condition_grade": condition_grade,
        "dmg_tag": dmg_tag
    })
    print("3번 과정 YOLO 손상 예측 끝")

    print("4번 과정 임시 파일 삭제 시작")
    # 4️⃣ 임시 파일 삭제
    try:
        os.remove(local_path)
    except:
        pass
    print("4번 과정 임시 파일 삭제 끝")

    # 5️⃣ 결과 반환
    return {
        "success": True,
        "title": title,
        "author": author,
        "publisher": publisher,
        "condition_grade": condition_grade,
        "dmg_tag": dmg_tag
    }

# -------------------------------
# 실행
# -------------------------------
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
