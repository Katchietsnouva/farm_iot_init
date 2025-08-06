import 'package:http/http.dart' as http;

class AIService {
  static Future<String> getResponse(String query) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: {
        'Authorization': 'Bearer YOUR_API_KEY',
        'Content-Type': 'application/json',
      },
      body: '{"model":"text-davinci-003","prompt":"$query","max_tokens":150}',
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to fetch AI response');
    }
  }
}


// class AiChatService {
//   String chatWithAI(String message) {
//     // Integrate AI chat functionality (e.g., using GPT)
//     return 'AI Response to: $message';
//   }
// }
