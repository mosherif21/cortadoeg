import 'package:get/get.dart';

String? validateTextOnly(String? value) {
  if (value == null || value.isEmpty) {
    return 'textEmpty'.tr;
  }
  final isCharactersOnly = RegExp(r'^[a-zA-Z\u0600-\u06FF ]+$').hasMatch(value);
  if (!isCharactersOnly) {
    return 'charactersOnly'.tr;
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'passwordRequired'.tr;
  }
  if (value.length < 8) {
    return 'password8long'.tr;
  }
  if (!value.contains(RegExp(r'[A-Z]'))) {
    return 'passwordUpperCase'.tr;
  }
  if (!value.contains(RegExp(r'[0-9]'))) {
    return 'passwordNumber'.tr;
  }
  return null;
}

String? validateNationalId(String? value) {
  if (value == null || value.isEmpty) {
    return 'idRequired'.tr;
  } else if (!GetUtils.isNumericOnly(value)) {
    return 'idNumbers'.tr;
  } else if (value.length != 14) {
    return 'idLength'.tr;
  }
  return null;
}

String? validateEmail(String? email) {
  if (email == null || email.isEmpty) {
    return 'emailRequired'.tr;
  } else if (!GetUtils.isEmail(email)) {
    return 'emailValid'.tr;
  }
  return null;
}
