# app.py
from flask import Flask, request, jsonify
from yolo_predict import predict_image
import os

app = Flask(__name__)

UPLOAD_FOLDER = "./uploads"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/predict", methods=["POST"])
def predict():
    if "file" not in request.files:
        return jsonify({"error": "No file provided"}), 400
    
    file = request.files["file"]
    if file.filename == "":
        return jsonify({"error": "Empty filename"}), 400

    # 파일 저장
    filepath = os.path.join(UPLOAD_FOLDER, file.filename)
    file.save(filepath)

    # YOLO 예측
    result_json = predict_image(filepath)
    
    # 파일 삭제 (옵션)
    os.remove(filepath)

    return result_json, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
