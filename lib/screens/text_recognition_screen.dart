// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:penai/models/custom_button.dart';
import 'package:penai/services/api_services.dart';
import 'package:penai/services/recognize.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';

class TextRecognitionScreen extends StatefulWidget {
  const TextRecognitionScreen({super.key});

  @override
  TextRecognitionScreenState createState() => TextRecognitionScreenState();
}

class TextRecognitionScreenState extends State<TextRecognitionScreen> {
  // final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  // final _script = TextRecognitionScript.latin;
  // final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  // CustomPaint? _customPaint;
  // String? _text;
  // var _cameraLensDirection = CameraLensDirection.back;
  String scannedText = '';
  bool isTyping = false;
  bool isImageLoaded = false;
  bool isLoading = false;

  final ApiServices openAIService = ApiServices();
  List<Map<String, dynamic>> recognizedTexts = [];
  bool showIcons = false;
  int selectedIndex = -1;
  List startedMessages = [];

  Future<void> saveStartedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedMessages =
        startedMessages.map((started) => jsonEncode(started)).toList();
    await prefs.setStringList('startedMessages', encodedMessages);
  }

  Future<void> loadStartedMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMessages = prefs.getStringList('startedMessages') ?? [];

    setState(() {
      if (savedMessages.isEmpty) {
      } else {
        startedMessages = savedMessages
            .map((started) => jsonDecode(started))
            .cast<String>() // Ensure this is dynamic
            .toList();
      }
    });
  }

  @override
  void dispose() async {
    // _textRecognizer.close();
    super.dispose();
  }

  void saveRecognisedText(String text) async {
    // String text = Recognizer.recognizeText(image);
    // final textRecognizer =
    //     TextRecognizer(script: TextRecognitionScript.latin);
    // final RecognizedText recognizedText = await textRecognizer
    //     .processImage(InputImage.fromFilePath(image.path));
    // String text = recognizedText.text.toString();
    // final inputImage = InputImage.fromFilePath(image.path);
    // final textDetector = GoogleMlKit.vision.textRecognizer();
    // RecognizedText recognizedText =
    //     await textDetector.processImage(inputImage);
    // await textDetector.close();
    // scannedText = '';
    // for (TextBlock block in recognizedText.blocks) {
    //   for (TextLine line in block.lines) {
    //     scannedText = "$scannedText${line.text} ";
    //   }
//}
    if (text == '') {
      showSnackbar('An error accourd, reload the picture again.');
    } else {
      recognizedTexts.insert(0, {'sender': 'user', 'message': text});
    }
    setState(() {
      isLoading = false;
    });
    saveRecognizedText();
  }

  Future<void> loadRecognizedTexts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMessages = prefs.getStringList('recognizedTexts') ?? [];

    setState(() {
      recognizedTexts = savedMessages
          .map((message) => jsonDecode(message))
          .cast<Map<String, dynamic>>()
          .toList();
    });
  }

  Future<void> saveRecognizedText() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedMessages =
        recognizedTexts.map((message) => jsonEncode(message)).toList();
    await prefs.setStringList('recognizedTexts', encodedMessages);
  }

  @override
  void initState() {
    super.initState();
    loadStartedMessages();
    loadRecognizedTexts();
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showSnackbar('Text copied to clipboard');
  }

  void readTextAloud(String text) {}

  Future<void> gptMessage(String message) async {
    var msg = await ApiServices.sendMessage(message);
    setState(() {
      recognizedTexts.insert(0, {'sender': 'gpt', 'message': msg});
      isTyping = false;
    });
    await saveRecognizedText();
  }

  Widget buildRecognizedText(Map<String, dynamic> text, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (showIcons && selectedIndex == index) {
            showIcons = false;
            selectedIndex = -1;
          } else {
            showIcons = true;
            selectedIndex = index;
          }
        });
      },
      child: Column(
        children: [
          // const SizedBox(
          //   height: 80,
          // ),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 6.0, horizontal: 6.0),
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: text['sender'] == 'user'
                        ? const Color.fromARGB(255, 6, 85, 141)
                        : const Color.fromARGB(255, 37, 39, 38),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          text['sender'] == 'user'
                              ? "assets/images/User.png"
                              : "assets/images/Bot.png",
                          height: 30,
                          width: 30,
                          color: Colors.white,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(
                          width: 9.0), // Add space between icon and text
                      Expanded(
                        child: SelectableText(
                          text['message'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                          cursorColor: const Color.fromARGB(255, 185, 89, 89),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if ((showIcons && selectedIndex == index) || index == 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconWithText(
                  icon: Icons.chat_bubble,
                  onPressed: () async {
                    await gptMessage(text['message']);
                    setState(() {
                      isTyping = false;
                    });
                  },
                ),
                const SizedBox(width: 9.0),
                IconWithText(
                  icon: Icons.copy,
                  onPressed: () {
                    copyToClipboard(text['message']);
                  },
                ),
                const SizedBox(width: 9.0),
                IconWithText(
                  icon: Icons.star_border_outlined,
                  onPressed: () {
                    startedMessages.add(text['message']);
                    saveStartedMessages();
                    showSnackbar('added to started messages');
                  },
                ),
                const SizedBox(width: 9.0),
                IconWithText(
                  icon: Icons.translate,
                  onPressed: () {
                    setState(() {});
                  },
                ),

                // Other icons...
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      // appBar: AppBar(
      //   title: const Text('Text Recognition'),
      // ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    Align(
                      child: Text(
                        'PEN AI',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      child: CustomIconButton(
                        height: 35,
                        width: 35,
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  children: [
                    // const SizedBox(height: 80),
                    for (var i = recognizedTexts.length - 1; i >= 0; i--)
                      buildRecognizedText(recognizedTexts[i], i),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: () async {
                    String text =
                        await Recognizer.processImage(ImageSource.gallery);
                    saveRecognisedText(text);
                  },
                  color: Colors.white,
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () async{
                     String text =
                        await Recognizer.processImage(ImageSource.camera);
                          saveRecognisedText(text);
                  },
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class IconWithText extends StatelessWidget {
  final IconData icon;

  final Function()? onPressed;

  const IconWithText({
    required this.icon,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color.fromARGB(255, 6, 85, 141),
          ),
        ],
      ),
    );
  }
}
