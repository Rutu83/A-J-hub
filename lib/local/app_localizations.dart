
import 'package:ajhub_app/local/language_en.dart';
import 'package:ajhub_app/local/language_guj.dart';
import 'package:ajhub_app/local/language_hi.dart';
import 'package:ajhub_app/local/languages.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';



class AppLocalizations extends LocalizationsDelegate<BaseLanguage> {
  const AppLocalizations();

  @override
  Future<BaseLanguage> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'gn':
        return LanguageGuj();
      case 'hi':
        return LanguageHindi();
      default:
        return LanguageEn();
    }
  }

  @override
  bool isSupported(Locale locale) => LanguageDataModel.languages().contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<BaseLanguage> old) => false;
}
