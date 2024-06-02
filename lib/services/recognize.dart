import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class Recognizer {
 static Future<String> processImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
       
        String text = await Recognizer.recognizeText(pickedImage);
        if (text != '') {
          return text;
        }
      }
    } catch (e) {
      //scannedText = 'Fail to load Image OR while scanning.';
    }
      return '';
  }

  static recognizeText(XFile image) async {
    try {
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer
          .processImage(InputImage.fromFilePath(image.path));
      String text = recognizedText.text.toString();
      textRecognizer.close();
      return text;
    } catch (e) {
      return '';
    }
  }
}
