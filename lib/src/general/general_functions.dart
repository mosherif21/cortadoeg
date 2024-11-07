import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cortadoeg/src/general/shared_preferences_functions.dart';
import 'package:cortadoeg/src/general/validation_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sweetsheet/sweetsheet.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/assets_strings.dart';
import '../constants/enums.dart';
import 'app_init.dart';
import 'common_widgets/language_select.dart';
import 'common_widgets/language_select_phone.dart';
import 'common_widgets/regular_bottom_sheet.dart';
import 'common_widgets/single_entry_screen.dart';

double getScreenHeight(BuildContext context) =>
    MediaQuery.of(context).size.height;

double getScreenWidth(BuildContext context) =>
    MediaQuery.of(context).size.width;

void showLoadingScreen() {
  final height = Get.context != null ? Get.context!.height : 200;
  Get.dialog(
    AlertDialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      content: PopScope(
        canPop: false,
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: LoadingAnimationWidget.inkDrop(
            color: Colors.white,
            size: height * 0.08,
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

void hideLoadingScreen() {
  Get.back();
}

void makeSystemUiTransparent() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ),
  );
}

void copyTextClipBoard({required String text}) =>
    Clipboard.setData(ClipboardData(text: text));

void shareText({required String text}) => Share.share(text);

void getToResetPasswordScreen() {
  Get.to(
    () => SingleEntryScreen(
      title: 'passwordResetLink'.tr,
      prefixIconData: Icons.email_outlined,
      lottieAssetAnim: kEmailVerificationAnim,
      textFormTitle: 'emailLabel'.tr,
      textFormHint: 'emailHintLabel'.tr,
      buttonTitle: 'confirm'.tr,
      inputType: InputType.email,
      validationFunction: validateEmail,
    ),
    transition: getPageTransition(),
  );
}

void showSnackBar({
  required String text,
  required SnackBarType snackBarType,
}) {
  if (Get.overlayContext != null) {
    late final AnimatedSnackBar snackBar;
    switch (snackBarType) {
      case SnackBarType.success:
        snackBar = AnimatedSnackBar.rectangle(
          duration: const Duration(seconds: 3),
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
          'success'.tr,
          text,
          type: AnimatedSnackBarType.success,
          brightness: Brightness.light,
        );
        break;
      case SnackBarType.error:
        snackBar = AnimatedSnackBar.rectangle(
          duration: const Duration(seconds: 3),
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
          'error'.tr,
          text,
          type: AnimatedSnackBarType.error,
          brightness: Brightness.light,
        );
        break;
      case SnackBarType.warning:
        snackBar = AnimatedSnackBar.rectangle(
          duration: const Duration(seconds: 3),
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
          'warning'.tr,
          text,
          type: AnimatedSnackBarType.warning,
          brightness: Brightness.light,
        );
        break;
      case SnackBarType.info:
        snackBar = AnimatedSnackBar.rectangle(
          duration: const Duration(seconds: 3),
          desktopSnackBarPosition: DesktopSnackBarPosition.topCenter,
          'info'.tr,
          text,
          type: AnimatedSnackBarType.info,
          brightness: Brightness.light,
        );
        break;
      default:
        AppInit.logger.e("Invalid SnackBarType provided.");
        return;
    }
    snackBar.show(
      Get.overlayContext!,
    );
  }
}

// Future<void> textToSpeech({required String text}) async {
//   final flutterTts = FlutterTts();
//
//   await flutterTts.setLanguage(isLangEnglish() ? 'en' : 'ar');
//
//   await flutterTts.speak(text);
// }

bool isLangEnglish() => AppInit.currentLanguage == Language.english;

void displayAlertDialog({
  required String title,
  required String body,
  required CustomSheetColor color,
  required String positiveButtonText,
  String? negativeButtonText,
  required Function positiveButtonOnPressed,
  Function? negativeButtonOnPressed,
  IconData? mainIcon,
  IconData? positiveButtonIcon,
  IconData? negativeButtonIcon,
  bool? isDismissible,
}) {
  if (Get.context != null) {
    final SweetSheet sweetSheet = SweetSheet();
    final context = Get.context!;
    sweetSheet.show(
        isDismissible: isDismissible ?? true,
        context: context,
        title: Text(title),
        description: Text(body),
        color: color,
        icon: mainIcon,
        positive: SweetSheetAction(
          onPressed: () => positiveButtonOnPressed(),
          title: positiveButtonText,
          icon: positiveButtonIcon,
        ),
        negative: negativeButtonText != null
            ? SweetSheetAction(
                onPressed: () => negativeButtonOnPressed!(),
                title: negativeButtonText,
                icon: negativeButtonIcon,
              )
            : null);
  }
}

Transition getPageTransition() {
  return AppInit.currentLanguage == Language.english
      ? Transition.rightToLeft
      : Transition.leftToRight;
}

void displayChangeLang() {
  if (Get.context != null) {
    final screenType = GetScreenType(Get.context!);
    screenType.isPhone
        ? RegularBottomSheet.showRegularBottomSheet(
            LanguageSelectPhone(
              onEnglishLanguagePress: () {
                setLocaleLanguageButton(
                  'en',
                );
              },
              onArabicLanguagePress: () {
                setLocaleLanguageButton(
                  'ar',
                );
              },
            ),
          )
        : showDialog(
            context: Get.context!,
            builder: (BuildContext context) {
              return LanguageSelect(
                onEnglishLanguagePress: () {
                  setLocaleLanguageButton(
                    'en',
                  );
                },
                onArabicLanguagePress: () {
                  setLocaleLanguageButton(
                    'ar',
                  );
                },
              );
            },
          );
  }
}

Future<void> launchURL({required String url}) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    showSnackBar(text: 'launchUrlFailed'.tr, snackBarType: SnackBarType.error);
    AppInit.logger.e('Couldn\'t launch url $uri');
    throw Exception('Could not launch $uri');
  }
}

Future<bool> handleStoragePermission() async => await handleGeneralPermission(
      permission: Permission.storage,
      deniedSnackBarText: 'enableStoragePermission'.tr,
      deniedForeverSnackBarTitle: 'storagePermission'.tr,
      deniedForeverSnackBarBody: 'storagePermissionDeniedForever'.tr,
    );

Future<bool> handleCameraPermission() async => await handleGeneralPermission(
      permission: Permission.camera,
      deniedSnackBarText: 'enableCameraPermission'.tr,
      deniedForeverSnackBarTitle: 'cameraPermission'.tr,
      deniedForeverSnackBarBody: 'cameraPermissionDeniedForever'.tr,
    );

Future<bool> handleContactsPermission() async => await handleGeneralPermission(
      permission: Permission.contacts,
      deniedSnackBarText: 'enableContactsPermission'.tr,
      deniedForeverSnackBarTitle: 'contactsPermission'.tr,
      deniedForeverSnackBarBody: 'contactsPermissionDeniedForever'.tr,
    );

Future<bool> handleCallPermission() async => await handleGeneralPermission(
      permission: Permission.phone,
      deniedSnackBarText: 'enableCallPermission'.tr,
      deniedForeverSnackBarTitle: 'callPermission'.tr,
      deniedForeverSnackBarBody: 'callPermissionDeniedForever'.tr,
    );

Future<bool> handleSmsPermission() async => await handleGeneralPermission(
      permission: Permission.sms,
      deniedSnackBarText: 'enableSmsPermission'.tr,
      deniedForeverSnackBarTitle: 'smsPermission'.tr,
      deniedForeverSnackBarBody: 'smsPermissionDeniedForever'.tr,
    );

Future<bool> handleNotificationsPermission() async =>
    await handleGeneralPermission(
      permission: Permission.notification,
      deniedSnackBarText: 'enableNotificationsPermission'.tr,
      deniedForeverSnackBarTitle: 'notificationsPermission'.tr,
      deniedForeverSnackBarBody: 'notificationsPermissionDeniedForever'.tr,
    );

Future<bool> handleGeneralPermission({
  required Permission permission,
  required String deniedSnackBarText,
  required String deniedForeverSnackBarTitle,
  required String deniedForeverSnackBarBody,
}) async {
  try {
    var permissionStatus = await permission.status;
    if (permissionStatus.isGranted) {
      return true;
    } else if (permissionStatus.isDenied) {
      permissionStatus = await permission.request();
    }

    if (permissionStatus.isGranted) {
      return true;
    } else if (permissionStatus.isDenied) {
      showSnackBar(text: deniedSnackBarText, snackBarType: SnackBarType.error);
    } else if (permissionStatus.isPermanentlyDenied) {
      displayAlertDialog(
        title: deniedForeverSnackBarTitle,
        body: deniedForeverSnackBarBody,
        positiveButtonText: 'goToSettings'.tr,
        negativeButtonText: 'cancel'.tr,
        positiveButtonOnPressed: () async {
          Get.back();
          if (!await openAppSettings()) {
            showSnackBar(
                text: deniedForeverSnackBarBody,
                snackBarType: SnackBarType.error);
          }
        },
        negativeButtonOnPressed: () => Get.back(),
        mainIcon: Icons.settings,
        color: SweetSheetColor.WARNING,
      );
    }
  } catch (err) {
    if (kDebugMode) {
      AppInit.logger.e(err.toString());
    }
  }

  return false;
}

class GetScreenType {
  final BuildContext context;

  GetScreenType(this.context);

  bool get isPhone => MediaQuery.of(context).size.width < 600;

  bool get isTablet =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  bool get isDesktop => MediaQuery.of(context).size.width >= 1200;
}

// String formatDateTime(Timestamp timestamp) {
//   DateTime dateTime =
//       DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
//   DateFormat formatter = DateFormat('MMM d y hh:mm a');
//   return formatter.format(dateTime);
// }

String getAddedCurrentTime({required int minutesToAdd}) {
  DateTime currentTime = DateTime.now();
  DateTime newTime = currentTime.add(Duration(minutes: minutesToAdd));
  return DateFormat.jm().format(newTime);
}

String getMinutesString(int minutes) {
  return minutes == 1
      ? 'minute'.tr
      : minutes == 2
          ? isLangEnglish()
              ? 'minutes'.tr
              : 'minute'.tr
          : minutes > 2 && minutes <= 10
              ? 'minutes'.tr
              : isLangEnglish()
                  ? 'minutes'.tr
                  : 'minute'.tr;
}
