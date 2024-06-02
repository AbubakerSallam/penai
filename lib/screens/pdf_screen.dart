// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:penai/services/api_services.dart';
import 'package:penai/services/lan_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:penai/models/custom_button.dart';

// ignore: library_prefixes

class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});

  @override
  State<PdfScreen> createState() => PdfScreenState();
}

class PdfScreenState extends State<PdfScreen> {
  late SharedPreferences prefs;
  final ApiPdfServices apiPdfServices = ApiPdfServices();
  bool _isLoading = false;
  Map<String, List<String>> pdfQAPairs = {};
  List<String> currentQAPairs = [];
  int currentQAPairIndex = 0;
  List<String> pdfNames = [];
  List savedpdfs = [];
  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        String? path = result.files.single.path;

        if (path != null) {
          await _handlePDFSelection(path);
          pdfNames.add(path.split('/').last); // Extract PDF name from path
        }
      }
    } catch (e) {
      throw Exception('Error picking PDF');
    }
  }

  Future<void> _handlePDFSelection(String filePath) async {
    try {
      setState(() {
        _isLoading = true;
      });

      String extractedText = await _extractTextFromPDF(filePath);
      List<String> generatedQAPairs = await _sendTextToGPT(extractedText);

      pdfQAPairs[filePath.split('/').last] = generatedQAPairs;
      String pdfname = filePath.split('/').last;
      savedpdfs.insert(0, {'sender': pdfname, 'message': pdfQAPairs});
      setState(() {
        currentQAPairs = generatedQAPairs;
        currentQAPairIndex = 0;
        _isLoading = false;
      });
      _savePreferences();
    } catch (e) {
      throw Exception('Error handling PDF');
    }
  }

  Future<String> _extractTextFromPDF(String filePath) async {
    try {
      final PdfDocument document =
          PdfDocument(inputBytes: File(filePath).readAsBytesSync());
      String text = PdfTextExtractor(document).extractText();
      document.dispose();

      return text;
    } catch (e) {
      throw Exception('Error extracting text from PDF');
    }
  }

  Future<List<String>> _sendTextToGPT(String text) async {
    String response = await apiPdfServices.pdfsendMessage(text);
    return response.split('\n');
  }

  @override
  void initState() {
    initTexts();
    super.initState();
    _loadPreferences();
  }

  Future<void> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMessages = prefs.getStringList('chatMessages') ?? [];

    setState(() {
      if (savedMessages.isEmpty) {
      } else {
        savedpdfs = savedMessages
            .map((message) => jsonDecode(message))
            .cast<Map<String, dynamic>>() // Ensure this is dynamic
            .toList();
      }
    });
  }

  Future<void> saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encodedMessages =
        savedpdfs.map((message) => jsonEncode(message)).toList();
    await prefs.setStringList('chatMessages', encodedMessages);
  }

  Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      pdfNames = prefs.getStringList('pdfNames') ?? [];
      pdfQAPairs = Map<String, List<String>>.from(
        Map.fromEntries(prefs.getKeys().where((key) => key == 'pdfNames').map(
          (key) {
            List<String>? qaPairs = prefs.getStringList(key);
            if (qaPairs != null) {
              return MapEntry<String, List<String>>(key, qaPairs);
            } else {
              String? singleQA = prefs.getString(key);
              if (singleQA != null) {
                return MapEntry<String, List<String>>(key, [singleQA]);
              }
            }
            // If neither List<String> nor String, return null
            return MapEntry<String, List<String>>(key, []);
          },
        )),
      );
    });
  }

  Future<void> _savePreferences() async {
    await prefs.setStringList('pdfNames', pdfNames);

    pdfQAPairs.forEach((pdfName, qaPairs) {
      for (int i = 0; i < qaPairs.length; i++) {
        String key = '$pdfName-$i';

        if (qaPairs[i] is List<String>) {
          prefs.setStringList(key, qaPairs[i] as List<String>);
        } else {
          prefs.setString(key, qaPairs[i]);
        }
      }
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: pdfNames.map((pdfName) {
                            return ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  currentQAPairs = pdfQAPairs[pdfName] ?? [];
                                  currentQAPairIndex = 0;
                                });
                              },
                              child: Text(pdfName),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  if (currentQAPairs.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (currentQAPairIndex + 1 != currentQAPairs.length) {
                            currentQAPairIndex =
                                currentQAPairs[currentQAPairIndex + 1].isEmpty
                                    ? (currentQAPairIndex + 2) %
                                        currentQAPairs.length
                                    : (currentQAPairIndex + 1) %
                                        currentQAPairs.length;
                          } else {
                            currentQAPairIndex = 0;
                          }
                        });
                      },
                      child: Card(
                        color: const Color.fromARGB(255, 49, 52, 54),
                        elevation: 14,
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            currentQAPairs[currentQAPairIndex],
                            style: const TextStyle(
                              fontFamily: 'Cera Pro',
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (currentQAPairs.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                            Color.fromARGB(255, 49, 52, 54),
                          )),
                          onPressed: () {
                            setState(() {
                              if (currentQAPairIndex - 1 > 0) {
                                currentQAPairIndex =
                                    currentQAPairs[currentQAPairIndex - 1]
                                            .isEmpty
                                        ? (currentQAPairIndex - 2) %
                                            currentQAPairs.length
                                        : (currentQAPairIndex - 1) %
                                            currentQAPairs.length;
                              } else {
                                currentQAPairIndex = 0;
                                showSnackbar('You are at fisrt.');
                              }
                            });
                          },
                          child: Text(
                            texts['back'] ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                            Color.fromARGB(255, 49, 52, 54),
                          )),
                          onPressed: () {
                            setState(() {
                              if (currentQAPairIndex + 1 !=
                                  currentQAPairs.length) {
                                currentQAPairIndex =
                                    currentQAPairs[currentQAPairIndex + 1]
                                            .isEmpty
                                        ? (currentQAPairIndex + 2) %
                                            currentQAPairs.length
                                        : (currentQAPairIndex + 1) %
                                            currentQAPairs.length;
                              } else {
                                currentQAPairIndex = 0;
                              }
                            });
                          },
                          child: Text(
                            texts['next'] ?? '',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 6, 85, 141),
        onPressed: () {
          _pickPDF();
        },
        child: const Icon(Icons.picture_as_pdf, color: Colors.white),
      ),
    );
  }
}
// D/DecorView[](32609): onWindowFocusChanged hasWindowFocus false
// D/DecorView[](32609): onWindowFocusChanged hasWindowFocus true