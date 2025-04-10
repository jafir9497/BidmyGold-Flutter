import 'package:get/get.dart';
import 'en_us_translations.dart';
import 'ta_in_translations.dart';
// Import other language files here

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'ta_IN': taIN,
        // Add other locales here
      };
}
