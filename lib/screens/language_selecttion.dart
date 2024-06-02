import 'package:penai/models/lan_pref.dart';
import 'package:flutter/material.dart';
import 'package:penai/models/custom_button.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final List<String> supportedLanguages = ['en', 'es', 'ar'];

  LanguageSelectionScreen({super.key}); // Add more languages as needed
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
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: supportedLanguages.length,
                itemBuilder: (context, index) {
                  String languageCode = supportedLanguages[index];
                  return ListTile(
                    minVerticalPadding: 2.5,

                    contentPadding: const EdgeInsets.all(5),
                    tileColor: const Color.fromARGB(
                        255, 6, 85, 141), // Background color
                    leading: const Icon(
                      Icons.language_sharp,
                      color: Colors.white,
                    ),
                    title: Text(
                      _getLanguageName(languageCode),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _changeLanguage(context, languageCode),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'ar':
        return 'العربية';
      default:
        return 'Unknown';
    }
  }

  Future<void> _changeLanguage(
      BuildContext context, String languageCode) async {
    await LanguagePreferences.saveLanguageCode(languageCode);
// exit(0);
    //Navigator.pop(context);
  }
}
