import 'package:get/get.dart';

class SignInWithEmailAndPasswordFailure {
  final String errorMessage;
  const SignInWithEmailAndPasswordFailure(
      [this.errorMessage = "An unknown error occurred"]);
  factory SignInWithEmailAndPasswordFailure.code(String code) {
    switch (code) {
      case 'user-not-found':
        return SignInWithEmailAndPasswordFailure('noRegisteredEmail'.tr);
      case 'wrong-password':
        return SignInWithEmailAndPasswordFailure('wrongPassword'.tr);
      default:
        return SignInWithEmailAndPasswordFailure('unknownError'.tr);
    }
  }
}
