from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
import numpy as np
from PIL import Image
import json
import io
import os

app = Flask(__name__)
CORS(app)

IMG_SIZE = 256

# If second/third prediction is lower than this, treat as one item only
MIXED_CONFIDENCE_THRESHOLD = 0.20

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "sortsnap_cnn_model.keras")
CLASS_NAMES_PATH = os.path.join(BASE_DIR, "class_names.json")

model = tf.keras.models.load_model(MODEL_PATH, compile=False)

with open(CLASS_NAMES_PATH, "r") as f:
    class_names = json.load(f)


def get_recyclable_status(predicted_class):
    recyclable_classes = ["plastic", "paper", "cardboard", "metal", "glass"]

    if predicted_class.lower() in recyclable_classes:
        return True

    return False


@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "success": True,
        "message": "SortSnap CNN API is running",
        "classes": class_names
    })


@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "success": True,
        "message": "CNN API health check OK."
    })


@app.route("/predict", methods=["POST"])
def predict():
    if "image" not in request.files:
        return jsonify({
            "success": False,
            "message": "No image uploaded. Please upload an image using form-data with key name 'image'."
        }), 400

    file = request.files["image"]

    try:
        img = Image.open(io.BytesIO(file.read())).convert("RGB")
        img = img.resize((IMG_SIZE, IMG_SIZE))

        img_array = tf.keras.preprocessing.image.img_to_array(img)
        img_array = np.expand_dims(img_array, axis=0)

        img_array = tf.keras.applications.efficientnet_v2.preprocess_input(img_array)

        predictions = model.predict(img_array, verbose=0)
        score = predictions[0]

        top_indices = np.argsort(score)[-3:][::-1]

        top_predictions = []

        for i in top_indices:
            item_name = class_names[int(i)]
            confidence = float(score[int(i)])
            confidence_percentage = round(confidence * 100, 2)

            top_predictions.append({
                "class": item_name,
                "itemName": item_name,
                "category": item_name,
                "confidence": round(confidence, 4),
                "confidencePercentage": confidence_percentage,
                "isRecyclable": get_recyclable_status(item_name)
            })

        main_classification = top_predictions[0]

        mixed_candidates = []

        for item in top_predictions[1:]:
            if item["confidence"] >= MIXED_CONFIDENCE_THRESHOLD:
                mixed_candidates.append(item)

        if len(mixed_candidates) > 0:
            detection_mode = "possible_mixed"
            classifications = [main_classification] + mixed_candidates
        else:
            detection_mode = "single"
            classifications = [main_classification]

        return jsonify({
            "success": True,
            "detectionMode": detection_mode,
            "classification": main_classification,
            "classifications": classifications,
            "top_predictions": top_predictions
        })

    except Exception as e:
        print("Prediction Error:", str(e))

        return jsonify({
            "success": False,
            "message": "Image prediction failed.",
            "error": str(e)
        }), 500


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    app.run(host="0.0.0.0", port=port)