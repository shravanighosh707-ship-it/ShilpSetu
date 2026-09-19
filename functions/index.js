require("dotenv").config();

const {setGlobalOptions} = require("firebase-functions");
const {onCall} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");
const {GoogleGenAI} = require("@google/genai");
const {v2: cloudinary} = require("cloudinary");

setGlobalOptions({maxInstances: 10});

const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
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

exports.uploadProductImage = onCall(async (request) => {
  if (!request.auth) {
    throw new Error("Authentication required.");
  }

  const {imageBase64, mimeType} = request.data || {};

  if (!imageBase64) {
    throw new Error("Product image is required.");
  }

  const imageType = mimeType || "image/jpeg";

  try {
    const result = await cloudinary.uploader.upload(
        `data:${imageType};base64,${imageBase64}`,
        {
          folder: `shilpsetu/products/${request.auth.uid}`,
          resource_type: "image",
        },
    );

    return {
      success: true,
      imageUrl: result.secure_url,
      publicId: result.public_id,
    };
  } catch (error) {
    logger.error("Cloudinary image upload failed", {
      message: error.message,
    });

    throw new Error("Failed to upload product image.");
  }
});
