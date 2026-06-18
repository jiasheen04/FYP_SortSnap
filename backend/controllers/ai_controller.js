const ILMU_API_KEY = process.env.ILMU_API_KEY;
const ILMU_BASE_URL = process.env.ILMU_BASE_URL || "https://api.ilmu.ai/v1";
const ILMU_MODEL = process.env.ILMU_MODEL || "ilmu-nemo-nano";

// Local CNN API first. Later on Render, set CNN_API_URL in environment variable.
const CNN_API_URL = process.env.CNN_API_URL || "http://127.0.0.1:5001";

async function callIlmu(messages, maxTokens = 500) {
  const response = await fetch(`${ILMU_BASE_URL}/chat/completions`, {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${ILMU_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: ILMU_MODEL,
      messages: messages,
      temperature: 0.3,
      max_tokens: maxTokens,
    }),
  });

  const data = await response.json();

  if (!response.ok) {
    console.error("ILMU API Error:", data);
    throw new Error(data.error?.message || "ILMU API request failed");
  }

  return data.choices?.[0]?.message?.content || "";
}

async function callCnnApi(file) {
  const formData = new FormData();

  const imageBlob = new Blob([file.buffer], {
    type: file.mimetype,
  });

  formData.append("image", imageBlob, file.originalname || "uploaded_image.jpg");

  const response = await fetch(`${CNN_API_URL}/predict`, {
    method: "POST",
    body: formData,
  });

  const data = await response.json();

  if (!response.ok || !data.success) {
    console.error("CNN API Error:", data);
    throw new Error(data.message || "CNN image prediction failed");
  }

  return data.classification;
}

function buildRecyclingPrompt(classification) {
  const itemName = classification.itemName || "unknown item";
  const category = classification.category || itemName;
  const confidencePercentage = classification.confidencePercentage || 0;
  const isRecyclable = classification.isRecyclable === true;

  return `
The CNN image classification model detected the uploaded item as "${itemName}".
Category: ${category}
Confidence: ${confidencePercentage}%
Recyclable: ${isRecyclable ? "Yes" : "No"}

Give a short recycling guidance message for a Cyberjaya user in Malaysia.

Requirements:
- Start with: "This looks like..."
- Mention the detected item.
- Explain what the user should do.
- Keep it beginner-friendly.
- Keep it short, around 3 to 5 sentences.
- If it is battery, mention special disposal and do not put it in normal recycling bin.
- If confidence is below 80%, say the image may be unclear and ask the user to type the item name if needed.
`;
}

// POST /api/chatbot/text
async function sendTextMessage(req, res) {
  try {
    const { question } = req.body;

    if (!question || question.trim() === "") {
      return res.status(400).json({
        success: false,
        message: "Question is required.",
      });
    }

    const messages = [
      {
        role: "system",
        content:
          "You are SortSnap, a recycling assistant for Cyberjaya users. Give short, clear, beginner-friendly recycling guidance. Focus on Malaysian recycling context. Do not give very long answers.",
      },
      {
        role: "user",
        content: question,
      },
    ];

    const answer = await callIlmu(messages, 500);

    return res.json({
      success: true,
      answer: answer,
      source: "ilmu",
    });
  } catch (error) {
    console.error("Text Chatbot Error:", error);

    return res.status(500).json({
      success: false,
      answer: "Sorry, I cannot answer right now. Please try again later.",
      source: "ilmu",
    });
  }
}

// POST /api/chatbot/classify-image
async function classifyImage(req, res) {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "Image file is required.",
      });
    }

    // 1. Send uploaded image to CNN API
    const classification = await callCnnApi(req.file);

    // 2. Send CNN result to ILMU for explanation
    const prompt = buildRecyclingPrompt(classification);

    const messages = [
      {
        role: "system",
        content:
          "You are SortSnap, a recycling assistant for Cyberjaya users. Use the CNN classification result to give short and practical recycling guidance. Do not mention technical backend details to the user.",
      },
      {
        role: "user",
        content: prompt,
      },
    ];

    const answer = await callIlmu(messages, 500);

    // 3. Return classification + ILMU answer to Flutter
    return res.json({
      success: true,
      classification: classification,
      answer: answer,
      source: "cnn + ilmu",
    });
  } catch (error) {
    console.error("Image Classification Error:", error);

    return res.status(500).json({
      success: false,
      classification: {
        category: "Unknown",
        confidence: 0.0,
        confidencePercentage: 0.0,
        itemName: "Unknown item",
        isRecyclable: false,
      },
      answer:
        "Sorry, I could not classify the image right now. Please type the item name in the chatbot, for example plastic bottle, cardboard box, or battery.",
      source: "cnn + ilmu",
      error: error.message,
    });
  }
}

module.exports = {
  sendTextMessage,
  classifyImage,
};