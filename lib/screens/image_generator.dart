// ignore_for_file: library_private_types_in_public_api, unnecessary_string_interpolations

import 'package:penai/models/custom_button.dart';
import 'package:penai/services/lan_service.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:penai/services/api_services.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final speechToText = SpeechToText();
  final TextEditingController _messageController = TextEditingController();
  bool isListening = false;
  final OpenAIService openAIService = OpenAIService();

  String userInputText = '';
  String? fetchedImageUrl; // Retrieved image URL
  bool isEmpte = true;
  @override
  void initState() {
    initTexts();
    super.initState();
    initSpeechToText();
  }

  Future<void> initSpeechToText() async {
    isListening = await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      userInputText = "${result.recognizedWords}";
    });
  }

  Future<void> stopListening() async {
    setState(() {});

    await speechToText.stop();
    if (userInputText != "") {
      fetchImage(userInputText);

      setState(() {});
    }
  }

  Future<void> fetchImage(String importImage) async {
    final res = await ApiServices.dallEAPI(importImage);

    fetchedImageUrl = res;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(title: const Text('Input & Image')),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    margin: const EdgeInsets.symmetric(horizontal: 20)
                        .copyWith(top: 40),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 6, 85, 141),
                      ),
                      borderRadius: BorderRadius.circular(20).copyWith(
                        topLeft: Radius.zero,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        userInputText != ""
                            ? userInputText
                            : texts['hi_how_can_i_help'] ?? '',
                        style: TextStyle(
                          fontFamily: 'Cera Pro',
                          color: Colors.white,
                          fontSize: userInputText != "" ? 15 : 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  if (fetchedImageUrl != null)
                    Padding(
                      padding: const EdgeInsets.all(27.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(fetchedImageUrl!),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(9),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _messageController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration.collapsed(
                        hintText: texts['create_image'] ?? '',
                        hintStyle: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _messageController.text.isEmpty,
                    child: IconButton(
                      onPressed: () async {
                        if (isListening) {
                          userInputText = "";
                          startListening();
                          setState(() {});
                        } else {
                          stopListening();
                          setState(() {});
                          stopListening();
                        }
                      },
                      icon: Icon(
                          speechToText.isListening ? Icons.stop : Icons.mic,
                          color: const Color.fromARGB(255, 6, 85, 141)),
                    ),
                  ),
                  const SizedBox(height: 3.0),
                  IconButton(
                    onPressed: () async {
                      if (_messageController.text.isNotEmpty) {
                        String message = _messageController.text;
                        userInputText = message;
                        setState(() {});
                        _messageController.clear();
                        fetchImage(userInputText);

                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.send,
                        color: Color.fromARGB(255, 6, 85, 141)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
