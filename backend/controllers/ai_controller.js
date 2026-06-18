const ILMU_API_KEY = process.env.ILMU_API_KEY;
const ILMU_BASE_URL = process.env.ILMU_BASE_URL || "https://api.ilmu.ai/v1";
const ILMU_MODEL = process.env.ILMU_MODEL || "ilmu-nemo-nano";

// Local CNN API first. On Render, set CNN_API_URL to: https://sortsnap-cnn.onrender.com
const CNN_API_URL = process.env.CNN_API_URL || "http://127.0.0.1:8000";

async function callIlmu(messages, maxTokens = 500) {
  const response = await fetch(`${ILMU_BASE_URL}/chat/completions`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${ILMU_API_KEY}`,
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

  return data;
}

function buildSmartRecyclingPrompt(cnnResult) {
  const detectionMode = cnnResult.detectionMode || "single";
  const main = cnnResult.classification || {};

  const classifications = Array.isArray(cnnResult.classifications)
    ? cnnResult.classifications
    : [main];

  if (detectionMode === "possible_mixed" && classifications.length > 1) {
    const predictionList = classifications
      .map((item, index) => {
        return `${index + 1}. ${item.category} - ${item.confidencePercentage}% confidence - Recyclable: ${item.isRecyclable ? "Yes" : "No"
          }`;
      })
      .join("\n");

    return `
The image classification result shows more than one possible waste material.

Possible materials:
${predictionList}

Important:
This is not object detection, so do not say every item is definitely detected.
Use wording like "This image mainly looks like..." and "There may also be...".

Give recycling guidance for a Cyberjaya user in Malaysia.

Requirements:
- Start with: "This image mainly looks like..."
- Mention the main material first.
- Mention possible mixed materials only as possible.
- Tell the user to separate different materials before recycling.
- Give simple guidance for each possible material.
- Keep it beginner-friendly.
- Keep it around 4 to 6 sentences.
- Do not mention CNN, model, API, backend, or confidence score in the final answer.
`;
  }

  const itemName = main.itemName || "unknown item";
  const category = main.category || itemName;
  const confidencePercentage = main.confidencePercentage || 0;
  const isRecyclable = main.isRecyclable === true;

  return `
The uploaded image mainly contains one waste item.

Detected item: ${itemName}
Category: ${category}
Confidence: ${confidencePercentage}%
Recyclable: ${isRecyclable ? "Yes" : "No"}

Give recycling guidance for a Cyberjaya user in Malaysia.

Requirements:
- Start with: "This looks like..."
- Mention only this detected item.
- Do not mention possible mixed materials.
- Explain what the user should do.
- Keep it beginner-friendly.
- Keep it around 3 to 5 sentences.
- If confidence is below 80%, say the image may be unclear and ask the user to type the item name if needed.
- Do not mention CNN, model, API, backend, or confidence score in the final answer.
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

    const cnnResult = await callCnnApi(req.file);

    const mainClassification = cnnResult.classification || {
      category: "Unknown",
      confidence: 0.0,
      confidencePercentage: 0.0,
      itemName: "Unknown item",
      isRecyclable: false,
    };

    const classifications = Array.isArray(cnnResult.classifications)
      ? cnnResult.classifications
      : [mainClassification];

    const prompt = buildSmartRecyclingPrompt(cnnResult);

    const messages = [
      {
        role: "system",
        content:
          "You are SortSnap, a recycling assistant for Cyberjaya users. Use the image classification result to give short and practical recycling guidance. Do not mention technical backend details to the user.",
      },
      {
        role: "user",
        content: prompt,
      },
    ];

    const answer = await callIlmu(messages, 700);

    return res.json({
      success: true,
      detectionMode: cnnResult.detectionMode || "single",
      classification: mainClassification,
      classifications: classifications,
      top_predictions: cnnResult.top_predictions || classifications,
      answer: answer,
      source: "cnn + ilmu",
    });
  } catch (error) {
    console.error("Image Classification Error:", error);

    return res.status(500).json({
      success: false,
      detectionMode: "single",
      classification: {
        category: "Unknown",
        confidence: 0.0,
        confidencePercentage: 0.0,
        itemName: "Unknown item",
        isRecyclable: false,
      },
      classifications: [],
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