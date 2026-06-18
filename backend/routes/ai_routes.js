const express = require("express");
const multer = require("multer");
const router = express.Router();

const {
  sendTextMessage,
  classifyImage,
} = require("../controllers/ai_controller");

// Store uploaded image in memory only, not folder
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },
});

// Text chatbot
router.post("/text", sendTextMessage);

// Image classification
router.post("/classify-image", upload.single("image"), classifyImage);

module.exports = router;