import 'package:google_generative_ai/google_generative_ai.dart'; // Import the correct package

class GeminiProvider {
  final GenerativeModel model;

  GeminiProvider({required this.model});

  // Use generateContent to call the API and get a response
  Future<String> generateContent(String userMessage) async {
    try {
      // Prepare the content (text input) for the model
      final content = [Content.text(userMessage)];

      // Call generateContent method
      final response = await model.generateContent(content);

      // Return the generated response text
      return response.text ?? "No response received.";
    } catch (e) {
      rethrow; // Propagate errors if any
    }
  }
}
