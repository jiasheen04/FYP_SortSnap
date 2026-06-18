import os
import json
import numpy as np
from PIL import Image

import tensorflow as tf
from flask import Flask, request, jsonify
from flask_cors import CORS


app = Flask(__name__)
CORS(app)

MODEL_PATH = "sortsnap_cnn_model.keras"
CLASS_NAMES_PATH = "class_names.json"
IMG_SIZE = 256

# Load CNN model once when server starts
model = tf.keras.models.load_model(MODEL_PATH, compile=False)

# Load class names
with open(CLASS_NAMES_PATH, "r") as file:
    class_names = json.load(file)


def prepare_image(image_file):
    image = Image.open(image_file).convert("RGB")
    image = image.resize((IMG_SIZE, IMG_SIZE))

    image_array = np.array(image)
    image_array = np.expand_dims(image_array, axis=0)

    image_array = tf.keras.applications.efficientnet_v2.preprocess_input(image_array)

    return image_array


def get_recyclable_status(predicted_class):
    recyclable_classes = ["plastic", "paper", "cardboard", "metal", "glass"]

    if predicted_class in recyclable_classes:
        return True

    return False


@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "success": True,
        "message": "SortSnap CNN API is running."
    })


@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "success": True,
        "message": "CNN API health check OK."
    })


@app.route("/predict", methods=["POST"])
def predict():
    try:
        if "image" not in request.files:
            return jsonify({
                "success": False,
                "message": "No image file uploaded."
            }), 400

        image_file = request.files["image"]

        if image_file.filename == "":
            return jsonify({
                "success": False,
                "message": "Empty image file."
            }), 400

        image_array = prepare_image(image_file)

        predictions = model.predict(image_array)

        predicted_index = int(np.argmax(predictions[0]))
        predicted_class = class_names[predicted_index]
        confidence = float(predictions[0][predicted_index])

        is_recyclable = get_recyclable_status(predicted_class)

        return jsonify({
            "success": True,
            "classification": {
                "itemName": predicted_class,
                "category": predicted_class,
                "confidence": round(confidence, 4),
                "confidencePercentage": round(confidence * 100, 2),
                "isRecyclable": is_recyclable
            }
        })

    except Exception as error:
        print("Prediction Error:", error)

        return jsonify({
            "success": False,
            "message": "Image prediction failed.",
            "error": str(error)
        }), 500


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5001))
    app.run(host="0.0.0.0", port=port)