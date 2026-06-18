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

model = tf.keras.models.load_model("sortsnap_cnn_model.keras", compile=False)

with open("class_names.json", "r") as f:
    class_names = json.load(f)


def get_recyclable_status(predicted_class):
    recyclable_classes = ["plastic", "paper", "cardboard", "metal", "glass"]

    if predicted_class in recyclable_classes:
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

        predicted_index = int(np.argmax(score))
        predicted_class = class_names[predicted_index]
        confidence = float(score[predicted_index])
        confidence_percentage = round(confidence * 100, 2)

        top_indices = np.argsort(score)[-3:][::-1]

        top_predictions = [
            {
                "class": class_names[int(i)],
                "confidence": round(float(score[int(i)] * 100), 2)
            }
            for i in top_indices
        ]

        is_recyclable = get_recyclable_status(predicted_class)

        return jsonify({
            "success": True,
            "classification": {
                "itemName": predicted_class,
                "category": predicted_class,
                "confidence": round(confidence, 4),
                "confidencePercentage": confidence_percentage,
                "isRecyclable": is_recyclable
            },
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