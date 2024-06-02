// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:penai/models/custom_button.dart';
import 'package:penai/services/api_services.dart';
import 'package:penai/services/lan_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:penai/services/recognize.dart';

import 'package:image_picker/image_picker.dart';

class ChatGPTChatScreen extends StatefulWidget {
  const ChatGPTChatScreen({super.key});

  @override
  ChatGPTChatScreenState createState() => ChatGPTChatScreenState();
}

class ChatGPTChatScreenState extends State<ChatGPTChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SpeechToText speechToText = SpeechToText();
  int start = 200;
  int delay = 200;
  // late OpenAI openAI;
  bool isTyping = false;
  bool isListening = false;
  bool empty = true;
  String herdText = "";
  String speech = '';
  String chatText = "";
  String scannedText = '';
  bool isImageLoaded = false;
  bool isLoading = false;
  XFile? imageFile;
  ScrollController scrollController = ScrollController();
  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  scrollMethod() {
    scrollController.animateTo(scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  List chatMessages = [];
  List startedMessages = [];
  @override
  void initState() {
    initTexts();
    super.initState();
    initSpeechToText();
    loadStartedMessages();
    loadMessages();
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
  }

  Future<void> initSpeechToText() async {
    isListening = await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    herdText = "";
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    // ignore: unnecessary_string_interpolations
    herdText = "${result.recognizedWords}";
    setState(() {
      // ignore: unnecessary_string_interpolations
    });
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    if (herdText != "") {
      chatMessages.insert(0, {'sender': 'user', 'message': herdText});
      setState(() {
        isTyping = true;
      });
      await gptMessage(herdText);
    }
  }

  Future<void> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMessages = prefs.getStringList('chatMessages') ?? [];

    setState(() {
      if (savedMessages.isEmpty) {
        empty = true;
      } else {
        empty = false;
        chatMessages = savedMessages
            .map((message) => jsonDecode(message))
            .cast<Map<String, dynamic>>() // Ensure this is dynamic
            .toList();
      }
    });
  }

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
        empty = true;
      } else {
        empty = false;
        startedMessages = savedMessages
            .map((started) => jsonDecode(started))
            .cast<String>() // Ensure this is dynamic
            .toList();
      }
    });
  }

  Future<void> saveMessages() async {
    empty = false;
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedMessages =
        chatMessages.map((message) => jsonEncode(message)).toList();
    await prefs.setStringList('chatMessages', encodedMessages);
  }

  void userMessage(String message) async {
    _messageController.clear();
    setState(() {
      isTyping = true;
      chatMessages.insert(0, {'sender': 'user', 'message': message});
    });
    await gptMessage(message);
    await saveMessages();
  }

  Future<void> gptMessage(String message) async {
    String msg = await ApiServices.sendMessage(message);
    setState(() {
      chatMessages.insert(0, {'sender': 'gpt', 'message': msg});
      isTyping = false;
    });
    await saveMessages();
  }

  // Future<void> processImage(ImageSource source) async {
  //   try {
  //     final pickedImage = await ImagePicker().pickImage(source: source);
  //     if (pickedImage != null) {
  //       final recognizedText = await getRecognisedText(pickedImage);
  //       setState(() {
  //         scannedText = recognizedText;
  //         _messageController.text = scannedText;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       scannedText = 'Fail to load Image OR while scanning.';
  //     });
  //   }
  // }
  void saveRecognisedText(String text) async {
    if (text == '') {
      showSnackbar('An error accourd, reload the picture again.');
    } else {
      scannedText = text;
      _messageController.text = scannedText;
      // recognizedTexts.insert(0, {'sender': 'user', 'message': text});
    }
    setState(() {
      isLoading = false;
    });
    // saveRecognizedText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
            empty
                ? Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 50,
                          color: Color.fromARGB(255, 6, 85, 141),
                        ),
                        Text(
                          texts['no_messages'] ?? '',
                          style: const TextStyle(
                            fontSize: 28.0,
                            color: Color.fromARGB(255, 6, 85, 141),
                          ),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      controller: scrollController,
                      reverse: true,
                      itemCount: chatMessages.length,
                      itemBuilder: (context, index) {
                        return Column(
                          crossAxisAlignment:
                              chatMessages[index]['sender'] == 'user'
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 3),
                              child: chatMessages[index]['sender'] == 'user'
                                  ? Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 6, 85, 141),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: SelectableText(
                                                chatMessages[index]
                                                        ['message'] ??
                                                    '',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                                textDirection: chatMessages[
                                                                    index]
                                                                ['message'] !=
                                                            null &&
                                                        RegExp(r'[^\x00-\x7F]')
                                                            .hasMatch(
                                                                chatMessages[
                                                                        index]
                                                                    ['message'])
                                                    ? TextDirection.rtl
                                                    : TextDirection.ltr,
                                              ),
                                            ),
                                            const SizedBox(width: 18.0),
                                            Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                              child: ClipOval(
                                                child: Image.asset(
                                                  ('assets/images/User.png'),
                                                  height: 30,
                                                  width: 30,
                                                  fit: BoxFit.cover,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 37, 39, 38),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                              child: ClipOval(
                                                child: Image.asset(
                                                  ('assets/images/Bot.png'),
                                                  height: 30,
                                                  width: 30,
                                                  fit: BoxFit.cover,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: SelectableText(
                                                chatMessages[index]
                                                        ['message'] ??
                                                    '',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                                textDirection: chatMessages[
                                                                    index]
                                                                ['message'] !=
                                                            null &&
                                                        RegExp(r'[^\x00-\x7F]')
                                                            .hasMatch(
                                                                chatMessages[
                                                                        index]
                                                                    ['message'])
                                                    ? TextDirection.rtl
                                                    : TextDirection.ltr,
                                              ),
                                            ),
                                            const SizedBox(width: 18.0),
                                            GestureDetector(
                                              onTap: () {
                                                startedMessages.add(
                                                    chatMessages[index]
                                                        ['message']);
                                                saveStartedMessages();

                                                showSnackbar(
                                                    'added to started messages');
                                              },
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.transparent,
                                                ),
                                                child: const Icon(
                                                  size: 15,
                                                  Icons.star_border,
                                                  color: Color.fromARGB(
                                                      255, 6, 85, 141),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
            if (isTyping)
              const SizedBox(
                height: 7,
                child: SpinKitThreeBounce(
                  color: Colors.white,
                  size: 15,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        controller: _messageController,
                        onChanged: (value) {
                          setState(() {
                            // Update the UI based on the text field's value
                          });
                        },
                        decoration: InputDecoration.collapsed(
                          hintText: texts['how_can_i_help'] ?? '',
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    //duration: Duration(milliseconds: start + 3 * delay),
                    visible: _messageController.text.isEmpty && !isTyping,
                    child: GestureDetector(
                      onTapDown: (details) {
                        _showImagePickerOptions(context);
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.grey,
                        child: Icon(Icons.camera_alt_outlined),
                      ),
                    ),
                  ),
                  Visibility(
                    //duration: Duration(milliseconds: start + 3 * delay),
                    visible: _messageController.text.isEmpty && !isTyping,
                    child: GestureDetector(
                      onTapDown: (details) {
                        try {
                          herdText = "";
                          startListening();

                          setState(() {});
                        } catch (e) {
                          showSnackbar(e.toString());
                        }
                      },
                      onTapUp: (details) {
                        try {
                          setState(() {});
                        } catch (e) {
                          showSnackbar(e.toString());
                        }
                        stopListening();
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.grey,
                        child: Icon(isListening
                            ? Icons.mic_external_off_outlined
                            : Icons.mic_external_on_outlined),
                      ),
                    ),
                  ),
                  //const SizedBox(height: 3.0),
                  Visibility(
                    visible: _messageController.text.isNotEmpty && !isTyping,
                    child: IconButton(
                      onPressed: () {
                        if (_messageController.text.isNotEmpty) {
                          String message = _messageController.text;
                          userMessage(message);
                        }
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Color.fromARGB(255, 6, 85, 141),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isTyping,
                    child: const CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
            const Text(
              'proff.dev.',
              style: TextStyle(fontSize: 8.0, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color.fromARGB(255, 45, 112, 160),
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                ),
                title: const Text('Photo Library'),
                onTap: () async {
                  String text =
                      await Recognizer.processImage(ImageSource.gallery);
                  saveRecognisedText(text);
                  //  processImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: Colors.white,
                ),
                title: const Text('Camera'),
                onTap: () async {
                  String text =
                      await Recognizer.processImage(ImageSource.camera);
                  saveRecognisedText(text);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
