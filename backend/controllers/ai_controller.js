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

  const cnnBaseUrl = CNN_API_URL.replace(/\/$/, "");

  const response = await fetch(`${cnnBaseUrl}/predict`, {
    method: "POST",
    body: formData,
  });

  const rawText = await response.text();

  let data;

  try {
    data = JSON.parse(rawText);
  } catch (error) {
    console.error("CNN did not return JSON.");
    console.error("CNN status:", response.status);
    console.error("CNN response preview:", rawText.slice(0, 300));

    throw new Error(
      "CNN service is not ready yet. Please wait a while and try again."
    );
  }

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
    const materialList = classifications
      .map((item, index) => {
        return `${index + 1}. ${item.category} - Recyclable: ${item.isRecyclable ? "Yes" : "No"
          }`;
      })
      .join("\n");

    return `
The image classification result suggests possible mixed waste materials.

Possible materials:
${materialList}

Important:
This is not object detection, so do not say every item is definitely detected.
Use wording like "This image mainly looks like..." and "There may also be...".
Do not mention confidence score.

Give recycling guidance for a Cyberjaya user in Malaysia.

Use this format:

✅ Main result
Say what the image mainly looks like and mention possible mixed materials.

♻️ What to do
• Give practical steps for each possible material.
• Tell the user to separate different materials before recycling.
• Mention clean, dry, flatten, rinse, or special disposal if needed.

⚠️ Important note
Mention any warning or exception.

Rules:
- Keep it beginner-friendly.
- Keep it around 80 to 140 words.
- Do not mention CNN, model, API, backend, or confidence score.
`;
  }

  const itemName = main.itemName || "unknown item";
  const category = main.category || itemName;
  const isRecyclable = main.isRecyclable === true;

  return `
The uploaded image mainly contains one waste item.

Detected item: ${itemName}
Category: ${category}
Recyclable: ${isRecyclable ? "Yes" : "No"}

Give recycling guidance for a Cyberjaya user in Malaysia.

Use this format:

✅ Main result
Say what the item is.

♻️ What to do
• Give practical recycling or disposal steps.
• Mention whether to clean, dry, flatten, rinse, separate, or bring to special collection.

⚠️ Important note
Mention any warning or exception.

Rules:
- Mention only this detected item.
- Do not mention possible mixed materials.
- Keep it beginner-friendly.
- Keep it around 70 to 120 words.
- Do not mention CNN, model, API, backend, or confidence score.
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
        content: `
You are SortSnap, a recycling assistant for Cyberjaya users in Malaysia.

Answer style:
- Give useful recycling guidance, not too short.
- Use clear point form.
- Use this format when suitable:

✅ Quick answer
Give the direct answer in 1 or 2 sentences.

♻️ What to do
• Give practical steps.
• Explain how to prepare the item before recycling.
• Mention whether to clean, dry, flatten, separate, or bring to special collection.

⚠️ Important note
Mention exceptions or warnings if needed.

Important rules:
- If the user asks "say more detailed", give more explanation about the previous recycling topic if possible.
- If the user gives a condition, follow that condition. Example: if the user says "if it is completely made of paper", answer based on a fully paper item, not a plastic-lined cup.
- Do not contradict yourself.
- If unsure, say "usually" or "please check the recycling label/local guideline".
- Keep the answer around 80 to 140 words.
- Do not mention AI, backend, API, model, CNN, or confidence score.
        `,
      },
      {
        role: "user",
        content: question,
      },
    ];

    const answer = await callIlmu(messages, 700);

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