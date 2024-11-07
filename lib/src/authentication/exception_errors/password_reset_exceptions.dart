import 'package:get/get.dart';

class ResetPasswordFailure {
  final String errorMessage;
  const ResetPasswordFailure([this.errorMessage = "An unknown error occurred"]);
  factory ResetPasswordFailure.code(String code) {
    switch (code) {
      case 'invalid-email':
        return ResetPasswordFailure('invalidEmailEntered'.tr);
      case 'missing-email':
        return ResetPasswordFailure('missingEmail'.tr);
      case 'user-not-found':
        return ResetPasswordFailure('noRegisteredEmail'.tr);
      default:
        return ResetPasswordFailure('unknownError'.tr);
    }
  }
}
