import 'package:penai/screens/chatgpt_chat_screen.dart';
import 'package:penai/screens/home_screen.dart';
import 'package:penai/screens/settings_screen.dart';
import 'package:penai/screens/started_messages.dart';
import 'package:penai/screens/voice_chat.dart';
import 'package:penai/services/lan_service.dart';
import 'package:flutter/material.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;
  @override
  void initState() {
    initTexts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const HomeScreen(),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 49, 52, 54),
          unselectedItemColor: Colors.grey,
          elevation: 2,
          items: const [
            BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.send,
                color: Color.fromARGB(255, 6, 85, 141),
              ),
              icon: Icon(
                Icons.send,
                color: Color.fromARGB(255, 6, 85, 141),
              ),
              label: "ChatGPT",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.record_voice_over_outlined,
                color: Color.fromARGB(255, 6, 85, 141),
              ),
              icon: Icon(
                Icons.record_voice_over_outlined,
                color: Color.fromARGB(255, 6, 85, 141),
              ),
              label: "VoiceGPT",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.star_border_purple500,
                color: Color.fromARGB(255, 6, 85, 141),
              ),
              icon: Icon(
                Icons.star_border_outlined,
                color: Color.fromARGB(255, 6, 85, 141),
              ),
              label: "Started",
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.settings,
                color: Color.fromARGB(255, 6, 85, 141),
              ),
              icon: Icon(
                Icons.settings,
                color: Color.fromARGB(255, 6, 85, 141),
              ),
              label: "Settings",
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: (int index) => setState(() {
                _selectedIndex = index;
                if (_selectedIndex == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatGPTChatScreen(),
                    ),
                  );
                }
                if (_selectedIndex == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VoiceChat(),
                    ),
                  );
                }
                if (_selectedIndex == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StartedMessages(),
                    ),
                  );
                }
                if (_selectedIndex == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                }
              })),
    );
  }
}
