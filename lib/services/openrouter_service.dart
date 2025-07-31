import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/message.dart';

class OpenRouterService {
  static const String baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  late final String apiKey;

  OpenRouterService() {
    apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('OpenRouter API key not found in environment variables');
    }
  }

  Future<String> sendMessage(List<Message> messages) async {
    final systemMessage = {
      'role': 'system',
      'content':
          '''You are ShieldAi, a friendly cybersecurity expert assistant in the ShieldUp learning app.

RESPONSE STYLE GUIDELINES:
- For greetings, thanks, or simple questions: Give SHORT, friendly responses (1-2 sentences)
- For technical questions: Give detailed but well-organized explanations
- Use simple, clear language - avoid jargon when possible
- Be conversational and helpful, not robotic
- NEVER use markdown formatting like *, #, **, etc. - use plain text only
- Use emojis sparingly and naturally
- Keep responses focused and relevant

ABOUT SHIELDUP & CREATORS:
When asked about creators or developers:
- ShieldUp was developed by Fosu Francis Boateng and Robert Kweku Torkpo
- Both are 3rd-year Computer Science students at KNUST
- They built this app to make cybersecurity education accessible
- Connect with them:
  Francis LinkedIn: https://bit.ly/46PGuiG
  Francis GitHub: https://github.com/fbfrancis
  Robert GitHub: https://github.com/bobby874

YOUR EXPERTISE:
Help users with cybersecurity topics like:
- Threats and vulnerabilities
- Security best practices
- Incident response
- Network security
- Malware prevention
- Risk assessment

RESPONSE EXAMPLES:
User: "Thank you!"
You: "You're welcome! Happy to help with your cybersecurity learning! 😊"

User: "Hello"
You: "Hi there! I'm ShieldAi, ready to help you with cybersecurity questions. What would you like to learn about?"

User: "What is phishing?"
You: "Phishing is a cyber attack where criminals trick people into sharing sensitive information like passwords or credit card details.

How it works:
• Attackers send fake emails, texts, or websites that look legitimate
• They pretend to be from banks, social media, or other trusted sources
• When you enter your information, they steal it

Red flags to watch for:
• Urgent messages demanding immediate action
• Suspicious email addresses or URLs
• Poor grammar or spelling
• Requests for sensitive information

Always verify the source before clicking links or sharing personal data!"

Keep responses natural, helpful, and appropriately sized for the question asked.''',
    };

    final requestMessages = [
      systemMessage,
      ...messages
          .map((msg) => {'role': msg.role, 'content': msg.content})
          ,
    ];

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await http
            .post(
              Uri.parse(baseUrl),
              headers: {
                'Authorization': 'Bearer $apiKey',
                'HTTP-Referer': 'https://shieldup-app.com',
                'X-Title': 'ShieldAi - ShieldUp Cybersecurity Assistant',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({
                'model': 'deepseek/deepseek-r1-0528:free',
                'messages': requestMessages,
                'stream': false,
                'temperature': 0.7,
                'max_tokens': 1000,
                'timeout': 25,
              }),
            )
            .timeout(requestTimeout);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          String content = data['choices'][0]['message']['content'] as String;

          // Clean up the response - remove any remaining markdown
          content = _cleanMarkdown(content);

          return content;
        } else if (response.statusCode == 408 || response.statusCode == 504) {
          if (attempt < maxRetries) {
            final delay = Duration(seconds: attempt * 2);
            print(
              'Timeout on attempt $attempt, retrying in ${delay.inSeconds}s...',
            );
            await Future.delayed(delay);
            continue;
          }
          throw Exception(
            'Request timed out after $maxRetries attempts. Please try again.',
          );
        } else if (response.statusCode == 429) {
          if (attempt < maxRetries) {
            final delay = Duration(seconds: 10 + (attempt * 5));
            print('Rate limited, waiting ${delay.inSeconds}s before retry...');
            await Future.delayed(delay);
            continue;
          }
          throw Exception(
            'Rate limit exceeded. Please wait a moment and try again.',
          );
        } else {
          throw Exception(
            'API Error: ${response.statusCode} - ${response.body}',
          );
        }
      } on TimeoutException {
        if (attempt < maxRetries) {
          final delay = Duration(seconds: attempt * 3);
          print(
            'Request timed out on attempt $attempt, retrying in ${delay.inSeconds}s...',
          );
          await Future.delayed(delay);
          continue;
        }
        throw Exception(
          'Connection timed out after $maxRetries attempts. Please check your internet connection and try again.',
        );
      } catch (e) {
        if (attempt < maxRetries &&
            (e.toString().contains('timeout') ||
                e.toString().contains('408'))) {
          final delay = Duration(seconds: attempt * 2);
          print(
            'Error on attempt $attempt: $e, retrying in ${delay.inSeconds}s...',
          );
          await Future.delayed(delay);
          continue;
        }
        throw Exception('Failed to send message: $e');
      }
    }

    throw Exception('Failed to send message after $maxRetries attempts');
  }

  // Clean up markdown formatting from the response
  String _cleanMarkdown(String text) {
    // Remove markdown headers
    text = text.replaceAll(RegExp(r'^#{1,6}\s+'), '');

    // Remove bold/italic markers but keep the text
    text = text.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1');
    text = text.replaceAll(RegExp(r'\*(.*?)\*'), r'$1');
    text = text.replaceAll(RegExp(r'__(.*?)__'), r'$1');
    text = text.replaceAll(RegExp(r'_(.*?)_'), r'$1');

    // Clean up bullet points
    text = text.replaceAll(RegExp(r'^[\*\-\+]\s+', multiLine: true), '• ');

    // Remove extra asterisks and formatting
    text = text.replaceAll(RegExp(r'\*+'), '');
    text = text.replaceAll(RegExp(r'#+'), '');

    // Clean up multiple newlines
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return text.trim();
  }
}
