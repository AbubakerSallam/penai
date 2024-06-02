import 'package:penai/screens/language_selecttion.dart';
import 'package:penai/services/lan_service.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  // bool _isNotificationEnabled = true;
  // bool _isDarkModeEnabled = false;

  @override
  void initState() {
    initTexts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 37, 39, 38),
      // appBar: AppBar(
      //   title: const Text(
      //     'Settings',
      //   ),
      // ),
      body: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: SizedBox(
                  height: 200,
                  child: Image.asset('assets/images/splash.png'),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LanguageSelectionScreen(),
                  ),
                ),
                child: Container(
                  height: 60,
                  width: 60,
                  margin: const EdgeInsets.all(14),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 6, 85, 141),
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 18),
                    child: Text(
                      texts['change_language'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 230,
              ),
              Container(
                margin: const EdgeInsets.all(24),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(25),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 6, 85, 141),
                          borderRadius: BorderRadius.circular(25)),
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        texts['welcome_message'] ?? '',
                        // 'مرحبًا بك في تطبيق AdvancedAI\n هذا التطبيق تم تطويره بواسطة Abubaker Sallam, يقدم التطبيق إمكانية التحدث مع نموذج ChatGPT لتوليد نصوص, صور, والعديد من الميزات الأخرى.',
                        style: const TextStyle(
                            fontSize: 14.0, color: Colors.white),
                        textDirection: texts['welcome_message'] != null &&
                                RegExp(r'[^\x00-\x7F]')
                                    .hasMatch(texts['welcome_message']!)
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
