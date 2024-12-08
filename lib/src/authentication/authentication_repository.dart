import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/authentication/exception_errors/password_reset_exceptions.dart';
import 'package:cortadoeg/src/authentication/models.dart';
import 'package:cortadoeg/src/general/app_init.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/enums.dart';
import '../general/general_functions.dart';
import 'exception_errors/signin_email_password_exceptions.dart';
import 'exception_errors/signup_email_password_exceptions.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late final Rx<User?> fireUser;
  bool isUserLoggedIn = false;
  bool isUserRegistered = false;
  final isGoogleLinked = false.obs;
  final isEmailAndPasswordLinked = false.obs;
  final isFacebookLinked = false.obs;
  final isEmailVerified = false.obs;
  String verificationId = '';
  GoogleSignIn? googleSignIn;
  Role userRole = Role.cashier;
  late EmployeeModel employeeInfo;

  @override
  void onInit() {
    fireUser = Rx<User?>(_auth.currentUser);
    if (fireUser.value != null) {
      isUserLoggedIn = true;
    }
    fireUser.bindStream(_auth.userChanges());
    fireUser.listen((user) {
      if (user != null) {
        isEmailVerified.value = user.emailVerified;
        checkAuthenticationProviders();
      }
    });

    super.onInit();
  }

  Future<FunctionStatus> sendVerificationEmail() async {
    try {
      if (_auth.currentUser != null) {
        await _auth.setLanguageCode(isLangEnglish() ? 'en' : 'ar');
        await _auth.currentUser!.sendEmailVerification();
        await _auth.setLanguageCode('en');
        return FunctionStatus.success;
      }
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
    return FunctionStatus.failure;
  }

  void checkAuthenticationProviders() {
    final user = fireUser.value!;
    isGoogleLinked.value = user.providerData.any(
        (provider) => provider.providerId == GoogleAuthProvider.PROVIDER_ID);

    isFacebookLinked.value = user.providerData.any(
        (provider) => provider.providerId == FacebookAuthProvider.PROVIDER_ID);

    isEmailAndPasswordLinked.value = user.providerData.any(
        (provider) => provider.providerId == EmailAuthProvider.PROVIDER_ID);
  }

  Future<FunctionStatus> userInit() async {
    final String userId = fireUser.value!.uid;
    final firestoreEmployeesCollRef = _firestore.collection('employees');
    try {
      final snapshot = await firestoreEmployeesCollRef.doc(userId).get();
      if (snapshot.exists) {
        final userDoc = snapshot.data()!;
        employeeInfo = EmployeeModel.fromFirestore(userDoc, snapshot.id);
        userRole = employeeInfo.role;
        if (kDebugMode) {
          AppInit.logger.i(userRole);
        }
        setNotificationsLanguage();
        if (fireUser.value!.email != null) {
          final authenticationEmail = fireUser.value!.email!;
          if (authenticationEmail.isNotEmpty &&
              employeeInfo.email != authenticationEmail) {
            if (kDebugMode) {
              AppInit.logger.i(
                  'Firestore email is not equal to Authentication email, updating it...');
            }
            updateUserEmailFirestore(email: authenticationEmail);
          }
        }
        return FunctionStatus.success;
      } else {
        showSnackBar(
          text: 'emailNotRegistered'.tr,
          snackBarType: SnackBarType.info,
        );
        return FunctionStatus.failure;
      }
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.i(error.toString());
      }
      return FunctionStatus.failure;
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
      return FunctionStatus.failure;
    }
  }

  Future<FunctionStatus> setNotificationsLanguage() async {
    try {
      if (fireUser.value != null) {
        if (AppInit.notificationToken.isNotEmpty) {
          await _firestore
              .collection('fcmTokens')
              .doc(fireUser.value!.uid)
              .set({
            'fcmToken${AppInit.isAndroid ? 'Android' : 'Ios'}':
                AppInit.notificationToken,
            'notificationsLang': isLangEnglish() ? 'en' : 'ar',
          });
        }
      }
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.i(error.toString());
      }
      return FunctionStatus.failure;
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
      return FunctionStatus.failure;
    }
  }

  Future<void> updateUserEmailFirestore({required String email}) async {
    final userId = fireUser.value!.uid;
    final firestoreUsersCollRef = _firestore.collection('users');
    try {
      await firestoreUsersCollRef.doc(userId).update({'email': email});
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
  }

  Future<String> updateUserEmailAuthentication({required String email}) async {
    try {
      await fireUser.value!.updateEmail(email);
      return 'success';
    } on FirebaseAuthException catch (ex) {
      if (kDebugMode) {
        AppInit.logger.e(ex.code);
      }
      if (ex.code == 'invalid-email') {
        return 'invalidEmailEntered'.tr;
      } else if (ex.code == 'email-already-in-use') {
        return 'emailAlreadyExists'.tr;
      } else if (ex.code == 'missing-email') {
        return 'missingEmail'.tr;
      } else if (ex.code == 'requires-recent-log-in') {
        return 'requireRecentLoginError'.tr;
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
    return 'unknownError'.tr;
  }

  Future<FunctionStatus> updateUserPhoneFirestore(
      {required String phone}) async {
    final String userId = fireUser.value!.uid;
    final firestoreUsersCollRef = _firestore.collection('users');
    try {
      await firestoreUsersCollRef.doc(userId).update({'phoneNumber': phone});
      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
      return FunctionStatus.failure;
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
      return FunctionStatus.failure;
    }
  }

  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (fireUser.value != null) {
        AppInit.currentAuthType.value = AuthType.emailLogin;
        isUserLoggedIn = true;
        AppInit.goToInitPage();
        return 'success';
      }
    } on FirebaseAuthException catch (e) {
      final ex = SignUpWithEmailAndPasswordFailure.code(e.code);
      if (kDebugMode) {
        AppInit.logger.e('FIREBASE AUTH EXCEPTION : ${ex.errorMessage}');
      }
      return ex.errorMessage;
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
    return 'unknownError'.tr;
  }

  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (fireUser.value != null) {
        AppInit.currentAuthType.value = AuthType.emailLogin;
        isUserLoggedIn = true;
        AppInit.goToInitPage();
        return 'success';
      }
    } on FirebaseAuthException catch (e) {
      final ex = SignInWithEmailAndPasswordFailure.code(e.code);
      if (kDebugMode) {
        AppInit.logger.e('FIREBASE AUTH EXCEPTION : ${ex.errorMessage}');
      }

      return ex.errorMessage;
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
    return 'unknownError'.tr;
  }

  Future<String> signInWithGoogle() async {
    try {
      final googleUser = await getGoogleAuthCredentials();
      if (googleUser != null) {
        await _auth.signInWithCredential(googleUser.credential);
        if (fireUser.value != null) {
          isUserLoggedIn = true;
          AppInit.currentAuthType.value = AuthType.google;
          AppInit.goToInitPage();
          return 'success';
        }
      }
    } on FirebaseAuthException catch (ex) {
      if (kDebugMode) {
        AppInit.logger.e(ex.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
    return 'failedGoogleAuth'.tr;
  }

  void linkWithGoogle() async {
    showLoadingScreen();
    final returnCode = await linkWithGoogleCode();
    hideLoadingScreen();
    if (returnCode == 'successGoogleLink'.tr) {
      showSnackBar(text: returnCode, snackBarType: SnackBarType.success);
    } else {
      showSnackBar(text: returnCode, snackBarType: SnackBarType.error);
    }
  }

  Future<String> linkWithGoogleCode() async {
    try {
      await signOutGoogle();
      final googleUser = await getGoogleAuthCredentials();
      if (googleUser != null) {
        final googleAccountLinked =
            await isGoogleAccountConnectedToFirebaseUser(googleUser.email);
        if (googleAccountLinked) {
          return 'googleAccountInUse'.tr;
        } else {
          if (isGoogleLinked.value) {
            await fireUser.value!.unlink(GoogleAuthProvider.PROVIDER_ID);
          }
          await fireUser.value!.linkWithCredential(googleUser.credential);
          if (!isEmailAndPasswordLinked.value) {
            await fireUser.value!
                .reauthenticateWithCredential(googleUser.credential);
            await updateUserEmailAuthentication(email: googleUser.email);
            await updateUserEmailFirestore(email: googleUser.email);
            employeeInfo.email = googleUser.email;
          }
        }
        return 'successGoogleLink'.tr;
      } else {
        return 'failedGoogleLink'.tr;
      }
    } on FirebaseAuthException catch (ex) {
      if (kDebugMode) {
        AppInit.logger.e(ex.code);
      }
      if (ex.code == 'credential-already-in-use') {
        return 'googleAccountInUse'.tr;
      } else if (ex.code == 'no-such-provider') {
        return 'failedGoogleLink'.tr;
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
    return 'failedGoogleLink'.tr;
  }

  Future<bool> isGoogleAccountConnectedToFirebaseUser(String email) async {
    try {
      final List<String> signInMethods =
          await _auth.fetchSignInMethodsForEmail(email);
      return signInMethods.contains('google.com');
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(
            'Error checking if Google account is connected to a Firebase user: $e');
      }

      return false;
    }
  }

  Future<void> signOutGoogle() async {
    if (await googleSignIn?.isSignedIn() ?? false) {
      await googleSignIn?.disconnect();
      await googleSignIn?.signOut();
    }
  }

  Future<GoogleUserModel?> getGoogleAuthCredentials() async {
    try {
      googleSignIn = AppInit.isWeb
          ? GoogleSignIn(
              clientId:
                  '571315776995-lfhqdgh7nk6rtpqh577ap4g7n76ig14m.apps.googleusercontent.com')
          : GoogleSignIn();
      final googleSignInAccount = await googleSignIn?.signIn();
      if (googleSignInAccount != null) {
        final signInAuthentication = await googleSignInAccount.authentication;
        final credential = GoogleAuthProvider.credential(
          idToken: signInAuthentication.idToken,
          accessToken: signInAuthentication.accessToken,
        );
        return GoogleUserModel(
            credential: credential, email: googleSignInAccount.email);
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
    return null;
  }

  Future<String> changeEmail(String newEmail, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
          email: fireUser.value!.email!, password: password);
      await fireUser.value!.reauthenticateWithCredential(credential);
      await fireUser.value!.updateEmail(newEmail);
      await updateUserEmailFirestore(email: newEmail);
      employeeInfo!.email = newEmail;
      return 'success';
    } on FirebaseAuthException catch (ex) {
      if (kDebugMode) {
        AppInit.logger.e('FIREBASE AUTH EXCEPTION : ${ex.toString()}');
      }
      if (ex.code == 'invalid-email') {
        return 'invalidEmailEntered'.tr;
      } else if (ex.code == 'email-already-in-use') {
        return 'emailAlreadyExists'.tr;
      } else if (ex.code == 'missing-email') {
        return 'missingEmail'.tr;
      } else if (ex.code == 'user-not-found') {
        return 'noRegisteredEmail'.tr;
      } else if (ex.code == 'wrong-password') {
        return 'wrongPassword'.tr;
      } else if (ex.code == 'requires-recent-login') {
        return 'requireRecentLoginError'.tr;
      }
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
    return 'unknownError'.tr;
  }

  Future<String> resetPassword({required String email}) async {
    String returnMessage = 'unknownError'.tr;
    try {
      await _auth.setLanguageCode(isLangEnglish() ? 'en' : 'ar');
      await _auth
          .sendPasswordResetEmail(email: email)
          .whenComplete(() => returnMessage = 'emailSent');
      await _auth.setLanguageCode('en');
    } on FirebaseAuthException catch (e) {
      final ex = ResetPasswordFailure.code(e.code);

      if (kDebugMode) {
        AppInit.logger.e('FIREBASE AUTH EXCEPTION : ${ex.errorMessage}');
      }
      return ex.errorMessage;
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
    return returnMessage;
  }

  // Future<String> signInWithFacebook() async {
  //   try {
  //     final facebookAuthCredential = await getFacebookAuthCredential();
  //     if (facebookAuthCredential != null) {
  //       await _auth.signInWithCredential(facebookAuthCredential);
  //       if (fireUser.value != null) {
  //         isUserLoggedIn = true;
  //         AppInit.currentAuthType.value = AuthType.facebook;
  //         AppInit.goToInitPage();
  //         return 'success';
  //       }
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       AppInit.logger.e(e.toString());
  //     }
  //   }
  //   return 'failedFacebookAuth'.tr;
  // }

  // Future<void> linkWithFacebook() async {
  //   try {
  //     showLoadingScreen();
  //     final facebookCredential = await getFacebookAuthCredential();
  //     if (facebookCredential != null) {
  //       await fireUser.value!.linkWithCredential(facebookCredential);
  //       hideLoadingScreen();
  //       showSnackBar(
  //           text: 'successFacebookLink'.tr, snackBarType: SnackBarType.success);
  //     }
  //   } catch (e) {
  //     hideLoadingScreen();
  //     showSnackBar(
  //         text: 'failedFacebookLink'.tr, snackBarType: SnackBarType.error);
  //     if (kDebugMode) {
  //       AppInit.logger.e(e.toString());
  //     }
  //   }
  // }

  // Future<OAuthCredential?> getFacebookAuthCredential() async {
  //   try {
  //     if (AppInit.isWeb) {
  //       await FacebookAuth.i.webAndDesktopInitialize(
  //         appId: "474331258229503",
  //         cookie: true,
  //         xfbml: true,
  //         version: "v14.0",
  //       );
  //     }
  //     final result = await FacebookAuth.instance.login();
  //     if (result.status == LoginStatus.success) {
  //       final credential =
  //           FacebookAuthProvider.credential(result.accessToken!.tokenString);
  //       return credential;
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       AppInit.logger.e(e.toString());
  //     }
  //   }
  //   return null;
  // }

  Future<void> logoutAuth() async {
    await _auth.signOut();
  }

  Future<void> logoutAuthUser() async {
    try {
      await logoutAuth();
      await signOutGoogle();
      isUserRegistered = false;
      isUserLoggedIn = false;
      isGoogleLinked.value = false;
      isEmailAndPasswordLinked.value = false;
      isFacebookLinked.value = false;
      isEmailVerified.value = false;
      verificationId = '';
      userRole = Role.cashier;
      employeeInfo = EmployeeModel(
        id: '',
        name: '',
        email: '',
        phone: '',
        role: Role.cashier,
        permissions: [],
      );
    } on FirebaseAuthException catch (ex) {
      if (kDebugMode) {
        AppInit.logger.e(ex.code);
      }
    } catch (e) {
      if (kDebugMode) e.printError();
    }
  }
}

class GoogleUserModel {
  final OAuthCredential credential;
  final String email;

  GoogleUserModel({
    required this.credential,
    required this.email,
  });
}
