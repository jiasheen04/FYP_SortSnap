const ILMU_API_KEY = process.env.ILMU_API_KEY;
const ILMU_BASE_URL = process.env.ILMU_BASE_URL || "https://api.ilmu.ai/v1";
const ILMU_MODEL = process.env.ILMU_MODEL || "ilmu-nemo-nano";

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
    throw new Error(data.error?.message || "ILMU API request failed");
  }

  return data.choices?.[0]?.message?.content || "";
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function callCnnApi(file) {
  const cnnBaseUrl = CNN_API_URL.replace(/\/$/, "");
  const maxAttempts = 4;

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      const formData = new FormData();

      const imageBlob = new Blob([file.buffer], {
        type: file.mimetype,
      });

      formData.append(
        "image",
        imageBlob,
        file.originalname || "uploaded_image.jpg"
      );

      const response = await fetch(`${cnnBaseUrl}/predict`, {
        method: "POST",
        body: formData,
      });

      const rawText = await response.text();

      let data;

      try {
        data = JSON.parse(rawText);
      } catch (jsonError) {

        if (attempt < maxAttempts) {
          await sleep(30000);
          continue;
        }

        throw new Error(
          "CNN service is still waking up. Please wait a while and try again."
        );
      }

      if (!response.ok || !data.success) {

        if (attempt < maxAttempts) {
          await sleep(30000);
          continue;
        }

        throw new Error(data.message || "CNN image prediction failed");
      }

      return data;
    } catch (error) {

      if (attempt < maxAttempts) {
        await sleep(30000);
        continue;
      }

      throw error;
    }
  }

  throw new Error("CNN image prediction failed after retrying.");
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
- If more than one possible material is listed, say the image might be mixed waste.
- Mention the possible materials shown above, but use uncertain wording like "might", "may", or "looks like".
- Keep it beginner-friendly.
- Keep it around 70 to 120 words.
- Do not mention CNN, model, API, backend, or confidence score.
- Reply in the same language as the user's app conversation if available.
- If there is no user language context, reply in English.
- Translate section headings fully.
- Do not mix English headings with Malay or Chinese answer.
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

function cleanTextAnswer(answer) {
  if (!answer) return "";

  return answer
    .replace(
      /^\s*✅\s*(Quick answer|Jawapan ringkas|简短回答)\s*\n\s*♻️\s*(What to do|Apa perlu dibuat|应该怎么做)\s*\n\s*⚠️\s*(Important note|Nota penting|重要提醒)\s*\n+/i,
      ""
    )
    .trim();
}


// POST /api/chatbot/text
async function sendTextMessage(req, res) {
  try {
    const { question, chatHistory = [] } = req.body;

    if (!question || question.trim() === "") {
      return res.status(400).json({
        success: false,
        message: "Question is required.",
      });
    }

    const recentHistory = Array.isArray(chatHistory)
      ? chatHistory.slice(-8)
      : [];

    const historyMessages = recentHistory
      .filter((msg) => msg.text && msg.text.trim() !== "")
      .map((msg) => ({
        role: msg.isUser ? "user" : "assistant",
        content: msg.text,
      }));

    const messages = [
      {
        role: "system",
        content: `
You are SortSnap, a recycling assistant for Cyberjaya users in Malaysia.

Language rule:
- Decide the reply language only from the user's latest question.
- Do not decide language from old chat history, app location, or Malaysia context.
- If the latest question is English, reply fully in English only.
- If the latest question is Malay, reply fully in Malay only.
- If the latest question is Chinese, reply fully in Simplified Chinese only.
- Do not use Traditional Chinese.
- Do not mix languages unless the user's latest question mixes languages.
- Section headings must use the same language as the user's latest question.
- If the latest question is English, never use other languages for headings.

Input understanding rule:
- The user may type with spelling mistakes, short forms, or casual Malaysian English.
- Understand common short forms:
  - "u" = you
  - "ur" = your
  - "pls" / "plz" = please
  - "dk" / "idk" = do not know
  - "dw" = do not want
  - "dun" / "dont" = do not
  - "nid" = need
  - "abt" = about
  - "bc" / "bcs" = because
  - "wat" / "waht" = what
- Understand correction phrases even if typed casually:
  - "where is paper" = user means there is no paper
  - "it is plastic only" = only plastic should be discussed
  - "u wrong" = previous answer/classification may be wrong
  - "not this" = user is correcting the result
- Do not copy the user's typo. Reply using clean and clear language.

Correction rule:
- If the user corrects a previous image scan result, trust the user's correction more than the image classification.
- Example: if previous result said "paper and plastic", but user says "it is plastic bag only", then answer only about plastic bag.
- Do not repeat the incorrect category after the user corrects it.
- Briefly acknowledge the correction, then give the correct recycling guidance.

Use only one answer format based on the user's latest question language.
Do not mix formats from different languages.

For English, write like this:
✅ Quick answer
Write the short answer here.

♻️ What to do
Write the action steps here.

⚠️ Important note
Write the warning or exception here.

For Malay, write like this:
✅ Jawapan ringkas
Tulis jawapan ringkas di sini.

♻️ Apa perlu dibuat
Tulis langkah yang perlu dibuat di sini.

⚠️ Nota penting
Tulis amaran atau pengecualian di sini.

For Chinese, write like this:
✅ 简短回答
在这里写简短回答。

♻️ 应该怎么做
在这里写处理步骤。

⚠️ 重要提醒
在这里写提醒或例外情况。

Important formatting rule:
- Do not print the three headings as a separate list at the top.
- Every heading must have content directly under it.
- Start the answer directly with "✅ Quick answer" and its content.
- If the latest question is English, use only:
  ✅ Quick answer
  ♻️ What to do
  ⚠️ Important note
- If the latest question is Malay, use only:
  ✅ Jawapan ringkas
  ♻️ Apa perlu dibuat
  ⚠️ Nota penting
- If the latest question is Chinese, use only:
  ✅ 简短回答
  ♻️ 应该怎么做
  ⚠️ 重要提醒

Answer style:
- Give useful recycling guidance, not too short.
- Use clear point form when suitable.
- Keep the answer around 80 to 140 words.
- Use the section format when suitable.

Follow-up rule:
- You can understand follow-up questions using the chat history.
- If the user says "it", "that item", "say more", "more detail", "lebih detail", or "讲详细一点", use the previous conversation context.
- If the user gives a condition, follow that condition carefully.

Rules:
- Do not contradict yourself.
- If unsure, say "usually" or ask the user to check the recycling label/local guideline.
- Do not mention AI, backend, API, model, CNN, or confidence score.
`,
      },
      ...historyMessages,
      {
        role: "user",
        content: question,
      },
    ];

    const answer = await callIlmu(messages, 700);
    const cleanAnswer = cleanTextAnswer(answer);

    return res.json({
      success: true,
      answer: cleanAnswer,
      source: "ilmu",
    });
  } catch (error) {

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

    const rawChatHistory = req.body.chatHistory;
    const savedCorrection = (req.body.savedCorrection || "").toString().trim();

    let chatHistory = [];

    if (rawChatHistory) {
      try {
        chatHistory = JSON.parse(rawChatHistory);
      } catch (error) {
        chatHistory = [];
      }
    }

    const recentHistory = Array.isArray(chatHistory)
      ? chatHistory.slice(-10)
      : [];

    const historyText = recentHistory
      .filter((msg) => msg.text && msg.text.trim() !== "")
      .map((msg) => {
        return `${msg.isUser ? "User" : "Assistant"}: ${msg.text}`;
      })
      .join("\n");

    const correctionPrompt = savedCorrection
      ? `
    The user uploaded an image that has a saved correction in the database.

    Saved corrected item:
    ${savedCorrection}

    Use this saved correction as the correct item for this image.
    Ignore the image classification result if it conflicts with this correction.

    Give recycling guidance for a Cyberjaya user in Malaysia.

    Use this format:

    ✅ Main result
    Say what the corrected item is.

    ♻️ What to do
    Give practical recycling or disposal steps.

    ⚠️ Important note
    Mention any warning or exception.

    Rules:
    - Follow the saved correction.
    - Do not mention the wrong image classification.
    - Do not mention CNN, model, API, backend, database, or confidence score.
    - Keep it beginner-friendly.
    - Keep it around 70 to 120 words.
    `
      : buildSmartRecyclingPrompt(cnnResult);

    const prompt = `
    Previous chat history:
    ${historyText || "No previous chat history."}

    ${correctionPrompt}

    Use the previous chat history to check whether the user corrected a previous image result.

    Very important correction rule:
    - If any recent user message says the image result is wrong, trust the user's correction.
    - If the user says "this is ...", "it is ...", "actually ...", "not ...", "wrong", or "only ...", treat it as a possible correction.
    - If the correction conflicts with the image classification result, ignore the image classification result.
    - Answer based on the corrected item from the user.
    - Do not repeat the wrong classification after the user corrected it.

    Example:
    - If the image classification says paper and plastic, but the user said "it is plastic only", answer only about plastic.
    - If the user says "u wrong", "not paper", "this is bottle", or similar correction, follow the corrected item.

    Do not repeat the wrong classification after the user corrected it.
    `;

    const messages = [
      {
        role: "system",
        content: `
        You are SortSnap, a recycling assistant for Cyberjaya users.

        Use the image classification result to give short and practical recycling guidance.

        If previous chat history exists, use it to understand:
        - the user's language
        - previous correction
        - what item the user was discussing

        If the user corrected a previous image scan, trust the user's correction more than the image classification result.

        Do not mention technical backend details to the user.
        Do not mention CNN, model, API, backend, or confidence score.
        `,
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
      savedCorrectionUsed: savedCorrection !== "",
      savedCorrection: savedCorrection,
      answer: answer,
      source: "cnn + ilmu",
    });
  } catch (error) {

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
    });
  }
}

module.exports = {
  sendTextMessage,
  classifyImage,
};