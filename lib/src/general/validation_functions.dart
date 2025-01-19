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

String? textNotEmpty(String? value) {
  if (value == null || value.isEmpty) {
    return 'textEmpty'.tr;
  }
  return null;
}

String? isNumeric(String? value) {
  if (value == null || value.isEmpty) {
    return 'textEmpty'.tr;
  } else if (double.tryParse(value) == null) {
    return 'enterNumber'.tr;
  } else {
    return null;
  }
}

String? validateNumbersOnly(String? value) {
  if (value == null || value.isEmpty) {
    return 'textEmpty'.tr;
  }
  final validNumberFormat = RegExp(r'^(?:\+20|20|0)1[0-9]{9}$');
  if (!validNumberFormat.hasMatch(value.trim())) {
    return 'invalidPhoneNumber'.tr;
  }
  return null;
}

String? validateNumberIsDouble(String? value) {
  if (value == null || value.isEmpty) {
    return 'textEmpty'.tr;
  }

  final doubleValue = double.tryParse(value);
  if (doubleValue == null) {
    return 'invalidDouble'.tr;
  }

  return null;
}

String? validatePasscode(String? value) {
  if (value == null || value.isEmpty) {
    return 'textEmpty'.tr;
  }

  if (value.length != 6) {
    return 'invalidPasscodeLength'.tr;
  }

  final intValue = int.tryParse(value);
  if (intValue == null) {
    return 'invalidPasscodeFormat'.tr;
  }

  return null;
}

String? validateNumberIsInt(String? value) {
  if (value == null || value.isEmpty) {
    return 'textEmpty'.tr;
  }

  final intValue = int.tryParse(value);
  if (intValue == null) {
    return 'invalidInt'.tr;
  }
  return null;
}

String? numberNotEmpty(String? value) {
  if (value == null || value.isEmpty) {
    return 'textEmpty'.tr;
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
