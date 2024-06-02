// ignore_for_file: unnecessary_string_interpolations

import 'package:penai/models/custom_button.dart';
import 'package:penai/services/api_services.dart';
import 'package:penai/services/lan_service.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:avatar_glow/avatar_glow.dart';

class VoiceChat extends StatefulWidget {
  const VoiceChat({super.key});

  @override
  State<VoiceChat> createState() => _VoiceChatState();
}

class _VoiceChatState extends State<VoiceChat> {
  final SpeechToText speechToText = SpeechToText();
  final OpenAIService openAIService = OpenAIService();
  bool isListening = false;
  String lastWords = "";
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    initTexts();
    super.dispose();
    speechToText.stop();
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
      lastWords = "${result.recognizedWords}";
    });
  }

  Future<void> stopListening() async {
    setState(() {});

    await speechToText.stop();
    if (lastWords != "") {
      final String msg = await openAIService.isArtPromptAPI(lastWords);
      if (msg.contains('https')) {
        generatedImageUrl = msg;
        generatedContent = null;
        setState(() {});
      } else {
        generatedImageUrl = null;
        //"$generatedContent.'/n'. msg";

        generatedContent = msg;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   title: const Text('Voice Chat'),
      //   centerTitle: true,
      // ),
      body: SafeArea(
        child: Column(
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
            SingleChildScrollView(
              child: Container(
                height: 100,
                width: 100,
                margin: const EdgeInsets.only(top: 30),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 6, 85,
                      141), // You can replace this with your desired color
                  shape: BoxShape.circle,
                ),
                child: Container(
                  height: 123,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/Bot.png'),
                      colorFilter: ColorFilter.linearToSrgbGamma(),
                    ),
                  ),
                ),
              ),
            ),
            // chat bubble
            Container(
              // color: Colors.black54,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              margin:
                  const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 30),
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
                  generatedContent == null
                      ? texts['hi_how_can_i_help'] ?? ''
                      : generatedContent!,
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Colors.white,
                    fontSize: generatedContent == null ? 25 : 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AvatarGlow(
        animate: isListening,
        duration: const Duration(milliseconds: 500),
        glowColor: const Color.fromARGB(255, 6, 85, 141),
        repeat: true,
        child: GestureDetector(
          onTapDown: (details) {
            try {
              lastWords = "";
              startListening();

              setState(() {});
            } catch (e) {
              showSnackbar(e.toString());
            }
          },
          onTapUp: (details) {
            try {
              setState(() {
                generatedContent = lastWords;
              });
              stopListening();
              setState(() {});
            } catch (e) {
              showSnackbar(e.toString());
            }
          },
          child: CircleAvatar(
            backgroundColor: const Color.fromARGB(255, 6, 85, 141),
            radius: 25,
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              color: const Color.fromARGB(255, 37, 39, 38),
            ),
          ),
        ),
      ),
    );
  }
}
