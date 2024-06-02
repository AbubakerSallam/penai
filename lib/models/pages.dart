import 'package:penai/screens/chatgpt_chat_screen.dart';
import 'package:penai/screens/pdf_screen.dart';
import 'package:penai/screens/settings_screen.dart';
import 'package:penai/screens/text_recognition_screen.dart';
import 'package:penai/screens/voice_chat.dart';
import 'package:flutter/material.dart';
import 'package:penai/services/lan_service.dart';

import '../screens/image_generator.dart';

class Pages {
  String thumbnail;
  String name;
  String dicribtion;
  int index;
  Pages({
    required this.name,
    required this.dicribtion,
    required this.thumbnail,
    required this.index,
  });
  final List<Widget> screens = [
    const ChatGPTChatScreen(),
    const PdfScreen(),
    const VoiceChat(),
    const TextRecognitionScreen(),
    const ImageScreen(),
    const SettingsScreen(),
  ];
}

List<Pages> pagesList = [
  Pages(
    name: 'Chat GPT',
    index: 0,
    dicribtion: texts['chat'] ?? '',
    thumbnail: 'assets/images/Bot.png',
  ),
  Pages(
    name: 'PDF GPT',
    index: 1,
    dicribtion: texts['pdf'] ?? '',
    thumbnail: 'assets/images/Bot.png',
  ),
  Pages(
    name: 'Voice GPT',
    index: 2,
    dicribtion: texts['voice'] ?? '',
    thumbnail: 'assets/images/Bot.png',
  ),
  Pages(
    name: 'Text detuction',
    index: 3,
    dicribtion: texts['textdetection'] ?? '',
    thumbnail: 'assets/images/Bot.png',
  ),
];

class MorePages {
  String thumbnail;
  String name;
  String dicribtion;
  int index;
  MorePages({
    required this.name,
    required this.dicribtion,
    required this.thumbnail,
    required this.index,
  });
  final List<Widget> screens = [
    const ChatGPTChatScreen(),
    const PdfScreen(),
    const VoiceChat(),
    const ImageScreen(),
    const TextRecognitionScreen(),
    const SettingsScreen(),
  ];
}

List<MorePages> morepagesList = [
  MorePages(
    name: 'Chat GPT',
    index: 0,
    dicribtion: texts['chat'] ?? '',
    thumbnail: 'assets/images/Bot.png',
  ),
  MorePages(
    name: 'PDF GPT',
    index: 1,
    dicribtion: texts['pdf'] ?? '',
    thumbnail: 'assets/images/Bot.png',
  ),
  MorePages(
    name: 'Voice GPT',
    index: 2,
    dicribtion: texts['voice'] ?? '',
    thumbnail: 'assets/images/Bot.png',
  ),
  MorePages(
    name: 'Images Generating',
    index: 3,
    dicribtion: texts['images'] ?? '',
    thumbnail: 'assets/images/Bot.png',
  ),
  MorePages(
    name: 'Text detuction',
    index: 4,
    dicribtion: texts['textdetection'] ?? '',
    thumbnail: 'assets/images/Bot.png',
  ),
];
