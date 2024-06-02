// ignore_for_file: unused_element, camel_case_types

import 'package:penai/models/lan_pref.dart';
import 'package:penai/models/lan_texts.dart';

Map<String, String> texts = LanguageTexts.arabic;
// /*{
//   'greeting': 'مرحبا\nصباح الخير!',
//   'no_messages': 'لا توجد رسائل بعد!',
//   'how_can_i_help': 'كيف يمكنني مساعدتك؟',
//   'photo_library': 'مكتبة الصور',
//   'explore_categories': ' الفئات',
//   'see_all': 'اظهار الكل',
//   'hi_how_can_i_help': 'مرحبًا، كيف يمكنني مساعدتك اليوم؟',
//   'create_image': 'يمكنني إنشاء أي صورة لك!',
//   'select_language': 'اختر اللغة',
//   'back': 'العودة',
//   'next': 'التالي',
//   'activate_notifications': 'تفعيل الإشعارات',
//   'night_mode': 'الوضع الليلي',
//   'change_language': 'تغيير اللغة',
//   'welcome_message':
//       'مرحبًا بك في تطبيق PEN AI\nهذا التطبيق تم تطويره بواسطة Abubaker Sallam، يقدم التطبيق إمكانية التحدث مع نموذج ChatGPT لتوليد نصوص، صور، والعديد من الميزات الأخرى.',
//   'good_morning': 'صباح الخير، كيف يمكنني مساعدتك اليوم؟',
//   'voice': 'الدردشة بالصوت مع الذكاء الاصطناعي',
//   'chat': 'الدردشة مع الذكاء الاصطناعي',
//   'images': 'إنشاء صور مع الذكاء الاصطناعي',
//   'textdetection': 'اكتشاف النصوص في صورك',
//   'pdf': 'إنشاء أسئلة وأجوبة من ملف PDF الخاص بك',
// };*/

Future<void> initTexts() async {
  try {
    String languageCode = await LanguagePreferences.getLanguageCode();

    switch (languageCode) {
      case 'es':
        texts = LanguageTexts.spanish;
        break;
      case 'ar':
        texts = LanguageTexts.arabic;
        break;
      // Add more cases for other languages
      default:
        texts = LanguageTexts.english;
    }
  } catch (e) {
    //nothing
  }
}

class langet {
  langet() {
    initTexts();
  }
}
