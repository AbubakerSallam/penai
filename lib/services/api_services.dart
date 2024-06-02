// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiServices {
  static List<Map<String, String>> messages = [];
  static String baseUrl =
      "https://api.openai.com/v1/chat/completions"; // Fix the endpoint name
  static String apiKey = "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";
  static Map<String, String> header = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  static sendMessage(String message) async {
    messages.add({
      'role': 'user',
      'content': message,
    });
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: header,
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );
      // print(messages);
      if (res.statusCode == 200) {
        String data = utf8.decode(res.bodyBytes); // Ensure proper decoding
        String msg = jsonDecode(data)['choices'][0]['message']['content'];

        // String data = jsonDecode(res.body)['choices'][0]['message']['content'];
        // msg = data.trim();
        messages.add({
          'role': 'assistant',
          'content': msg,
        });
        return msg;
      } else {
        print("Failed to fetch data: ${res.body}");
        return "An Error accoured";
      }
    } catch (e) {
      print(e.toString);
      return "حدث خطأ ما, تحقق من وجود الإنترنت.";
    }
  }

  static dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occurred';
    } catch (e) {
      print(e.toString);
      return "An Error accoured";
    }
  }
}

class ApiPdfServices {
  static List<Map<String, String>> messages = [];
  static String baseUrl =
      "https://api.openai.com/v1/chat/completions"; // Fix the endpoint name
  static String apiKey = "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";
  static Map<String, String> header = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  Future<String> pdfsendMessage(String message) async {
    if (message.length > 4000) {
      message =
          message.substring(0, 4000); // Truncate the message to 4000 characters
    }
    // messages.add({
    //   'role': 'user',
    //   'content': message,
    // });
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: header,
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          // "model": "text-curie-003",
          "messages": [
            {
              'role': 'user',
              'content':
                  'Please generate Qs and As from the following text: $message ',
            }
          ],
        }),
      );
      if (res.statusCode == 200) {
        String data = jsonDecode(res.body)['choices'][0]['message']['content'];
        String msg = data.trim();
        messages.add({
          'role': 'assistant',
          'content': msg,
        });
        return msg;
      } else {
        print("Failed to fetch data: ${res.body}");
        return "An Error accoured";
      }
    } catch (e) {
      print(e.toString);
      return "An Error accoured";
    }
  }
}

class OpenAIService {
  final List<Map<String, String>> messages = [];
  static String apiKey = "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";

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              'role': 'user',
              'content':
                  'Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simply answer with a yes or no.',
            }
          ],
        }),
      );
      print(res.body);
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        switch (content) {
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
      return 'An internal error occurred';
    } catch (e) {
      print(e.toString);
      return "An Error accoured";
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
        }),
      );

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'An internal error occurred';
    } catch (e) {
      print(e.toString);
      return "An Error accoured";
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occurred';
    } catch (e) {
      print(e.toString);
      return "An Error accoured";
    }
  }
}
