require("dotenv").config();

const {setGlobalOptions} = require("firebase-functions");
const {onCall} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const {GoogleGenAI} = require("@google/genai");

setGlobalOptions({maxInstances: 10});

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

exports.generateProductCatalog = onCall(async (request) => {
  if (!request.auth) {
    throw new Error("Authentication required.");
  }

  const {imageBase64, mimeType} = request.data || {};

  if (!imageBase64) {
    throw new Error("Product image is required.");
  }

  const imageType = mimeType || "image/jpeg";

  try {
    const response = await ai.models.generateContent({
      model: "gemini-3.5-flash-lite",
      contents: [
        {
          role: "user",
          parts: [
            {
              text: `
Analyze this artisan product image and create a product catalog suggestion.

Return ONLY valid JSON:
{
  "suggestedName": "string",
  "suggestedDescription": "string",
  "suggestedCategory": "string",
  "suggestedCraftType": "string",
  "suggestedTags": ["string"]
}

Do not invent details that cannot reasonably be inferred from the image.
The result is only a suggestion and will be reviewed by the artisan.
`,
            },
            {
              inlineData: {
                mimeType: imageType,
                data: imageBase64,
              },
            },
          ],
        },
      ],
    });

    const output = response.text;

    if (!output) {
      throw new Error("AI returned an empty response.");
    }

    let catalog;

    try {
      const cleanedOutput = output
          .replace(/^```json\s*/i, "")
          .replace(/\s*```$/i, "")
          .trim();

      catalog = JSON.parse(cleanedOutput);
    } catch (error) {
      logger.error("AI returned invalid JSON", {
        output,
        error: error.message,
      });

      throw new Error("AI returned an invalid catalog response.");
    }

    return {
      success: true,
      catalog,
    };
  } catch (error) {
    logger.error("AI catalog generation failed", {
      message: error.message,
    });

    throw new Error("Failed to generate product catalog.");
  }
});
