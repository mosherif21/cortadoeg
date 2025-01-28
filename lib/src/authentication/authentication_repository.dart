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
  late EmployeeModel? employeeInfo;
  final userEmail = ''.obs;
  late StreamSubscription? employeesListener;
  @override
  void onInit() async {
    fireUser = Rx<User?>(_auth.currentUser);
    if (fireUser.value != null) {
      isUserLoggedIn = true;
    }
    fireUser.bindStream(_auth.userChanges());
    fireUser.listen((user) async {
      if (user != null) {
        isEmailVerified.value = user.emailVerified;
        checkAuthenticationProviders();
        if (user.email != null) {
          userEmail.value = user.email!;
        }
      }
    });

    super.onInit();
  }

  Future<String> resetPassword(String oldPassword, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
          email: userEmail.value, password: oldPassword);
      await fireUser.value!.reauthenticateWithCredential(credential);
      await fireUser.value!.updatePassword(password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      final ex = SignInWithEmailAndPasswordFailure.code(e.code);
      if (kDebugMode) {
        AppInit.logger.e('FIREBASE AUTH EXCEPTION : ${e.toString()}');
      }
      return ex.errorMessage;
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
    return 'unknownError'.tr;
  }

  Future<String> linkWithEmailAndPassword(String email, String password) async {
    try {
      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      await fireUser.value!.linkWithCredential(credential);
      await fireUser.value!.reauthenticateWithCredential(credential);
      await fireUser.value!.updateEmail(email);
      await updateUserEmailFirestore(email: email);
      employeeInfo?.email = email;
      return 'success';
    } on FirebaseAuthException catch (e) {
      final ex = SignUpWithEmailAndPasswordFailure.code(e.code);
      if (kDebugMode) {
        AppInit.logger.e('FIREBASE AUTH EXCEPTION : ${e.toString()}');
      }
      return ex.errorMessage;
    } catch (e) {
      if (kDebugMode) {
        AppInit.logger.e(e.toString());
      }
    }
    return 'unknownError'.tr;
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
        if (employeeInfo != null) {
          userRole = employeeInfo!.role;
          if (kDebugMode) {
            AppInit.logger.i('Employee role: ${userRole.name}');
          }
          setNotificationsLanguage();
          if (fireUser.value!.email != null) {
            final authenticationEmail = fireUser.value!.email!;
            userEmail.value = authenticationEmail;
            if (employeeInfo!.email.compareTo(authenticationEmail) != 0) {
              updateUserEmailFirestore(email: authenticationEmail);
              if (kDebugMode) {
                AppInit.logger.i(
                    'Firestore email is not equal to Authentication email, updating it...');
              }
            }
          }
          employeesListener = firestoreEmployeesCollRef
              .doc(userId)
              .snapshots()
              .listen((snapshot) {
            if (snapshot.exists) {
              final userDoc = snapshot.data()!;
              employeeInfo = EmployeeModel.fromFirestore(userDoc, snapshot.id);
              if (kDebugMode) {
                AppInit.logger.i('Employee info updated');
              }
            }
          });
          return FunctionStatus.success;
        }
      } else {
        showSnackBar(
          text: 'emailNotRegistered'.tr,
          snackBarType: SnackBarType.info,
        );
      }
      return FunctionStatus.failure;
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
    final firestoreUsersCollRef = _firestore.collection('employees');
    try {
      await firestoreUsersCollRef.doc(userId).update({'email': email});
      employeeInfo!.email = email;
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

  Future<FunctionStatus> updateEmployeePersonalInfo({
    required String name,
    required String phone,
    required String gender,
    required Timestamp birthDate,
  }) async {
    final userId = fireUser.value!.uid;
    final firestoreUsersCollRef = _firestore.collection('employees');
    try {
      await firestoreUsersCollRef.doc(userId).update({
        'name': name,
        'phone': phone,
        'gender': gender,
        'birthDate': birthDate,
      });
      return FunctionStatus.success;
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
    final firestoreUsersCollRef = _firestore.collection('employees');
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
            employeeInfo!.email = googleUser.email;
            userEmail.value = googleUser.email;
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
      await fireUser.value!.verifyBeforeUpdateEmail(newEmail);
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
      } else if (ex.code == 'invalid-credential') {
        return 'wrongCredentials'.tr;
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

  Future<String> sendResetPasswordLink({required String email}) async {
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

  Future<FunctionStatus> setNotificationsLanguage() async {
    try {
      if (employeeInfo == null || AppInit.notificationToken.isEmpty) {
        return FunctionStatus.failure;
      }

      final userId = employeeInfo!.id;
      String newLang = isLangEnglish() ? 'en' : 'ar';

      // Handle other roles (if needed)
      if (userRole != Role.admin &&
          userRole != Role.owner &&
          userRole != Role.cashier) {
        await _firestore.collection('fcmTokens').doc(fireUser.value!.uid).set({
          'fcmToken': AppInit.notificationToken,
          'notificationsLang': newLang,
        }, SetOptions(merge: true));
        return FunctionStatus.success;
      }
      DocumentReference tokenDocRef;
      String idFieldName;

      switch (userRole) {
        case Role.cashier:
          tokenDocRef =
              _firestore.collection('fcmTokens').doc('cashiersFcmTokens');
          idFieldName = 'cashierId';
          break;
        case Role.owner:
          tokenDocRef =
              _firestore.collection('fcmTokens').doc('ownersFcmTokens');
          idFieldName = 'ownerId';
          break;
        case Role.admin:
          tokenDocRef =
              _firestore.collection('fcmTokens').doc('adminsFcmTokens');
          idFieldName = 'adminId';
          break;
        default:
          return FunctionStatus.failure;
      }

      DocumentSnapshot tokenDocSnapshot = await tokenDocRef.get();
      List<Map<String, dynamic>> existingTokens = [];

      if (tokenDocSnapshot.exists) {
        final data = tokenDocSnapshot.data() as Map<String, dynamic>;
        final tokensList = data['tokens'];
        if (tokensList is List) {
          existingTokens =
              tokensList.whereType<Map<String, dynamic>>().toList();
        }
      }

      // Remove existing tokens for this user
      List<Map<String, dynamic>> updatedTokens = existingTokens.where((token) {
        return token[idFieldName] != userId;
      }).toList();

      // Add new token

      updatedTokens.add({
        'fcmToken': AppInit.notificationToken,
        'notificationsLang': newLang,
        idFieldName: userId,
      });

      // Update Firestore with the modified tokens
      await tokenDocRef.update({'tokens': updatedTokens});

      return FunctionStatus.success;
    } on FirebaseException catch (error) {
      if (kDebugMode) AppInit.logger.i(error.toString());
      return FunctionStatus.failure;
    } catch (e) {
      if (kDebugMode) AppInit.logger.e(e.toString());
      return FunctionStatus.failure;
    }
  }

  Future<void> resetFcmTokens() async {
    try {
      if (employeeInfo == null) return;

      if (employeeInfo!.role != Role.admin &&
          employeeInfo!.role != Role.owner &&
          employeeInfo!.role != Role.cashier) {
        await _firestore.collection('fcmTokens').doc(employeeInfo!.id).delete();
        return;
      }
      String documentId;
      String idFieldName;

      switch (employeeInfo!.role) {
        case Role.cashier:
          documentId = 'cashiersFcmTokens';
          idFieldName = 'cashierId';
          break;
        case Role.owner:
          documentId = 'ownersFcmTokens';
          idFieldName = 'ownerId';
          break;
        case Role.admin:
          documentId = 'adminsFcmTokens';
          idFieldName = 'adminId';
          break;
        default:
          return;
      }

      DocumentReference tokenDocRef =
          _firestore.collection('fcmTokens').doc(documentId);
      DocumentSnapshot tokenDocSnapshot = await tokenDocRef.get();
      List<Map<String, dynamic>> existingTokens = [];

      if (tokenDocSnapshot.exists) {
        final data = tokenDocSnapshot.data() as Map<String, dynamic>;
        final tokensList = data['tokens'];
        if (tokensList is List) {
          existingTokens =
              tokensList.whereType<Map<String, dynamic>>().toList();
        }
      }

      // Remove user's tokens
      List<Map<String, dynamic>> updatedTokens = existingTokens.where((token) {
        return token[idFieldName] != employeeInfo!.id;
      }).toList();

      await tokenDocRef.update({'tokens': updatedTokens});
    } catch (e) {
      if (kDebugMode) print('Error resetting FCM tokens: $e');
    }
  }

  Future<void> logoutAuth() async {
    await _auth.signOut();
  }

  Future<FunctionStatus> logoutAuthUser() async {
    try {
      await employeesListener?.cancel();
      await resetFcmTokens();
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
      employeeInfo = null;
      return FunctionStatus.success;
    } on FirebaseAuthException catch (ex) {
      if (kDebugMode) {
        AppInit.logger.e(ex.code);
      }
    } catch (e) {
      if (kDebugMode) e.printError();
    }
    return FunctionStatus.failure;
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
