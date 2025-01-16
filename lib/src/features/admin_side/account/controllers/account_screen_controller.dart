import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/authentication/models.dart';
import 'package:cortadoeg/src/constants/enums.dart';
import 'package:cortadoeg/src/features/cashier_side/account/components/login_password_screen.dart';
import 'package:cortadoeg/src/features/cashier_side/account/components/personal_info_screen.dart';
import 'package:cortadoeg/src/features/cashier_side/account/components/photo_select.dart';
import 'package:cortadoeg/src/features/cashier_side/account/controllers/login_password_form_controller.dart';
import 'package:cortadoeg/src/features/cashier_side/account/controllers/personal_info_form_controller.dart';
import 'package:cortadoeg/src/general/app_init.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../authentication/authentication_repository.dart';
import '../../../../general/common_widgets/regular_bottom_sheet.dart';
import '../../../../general/general_functions.dart';
import '../components/photo_select_phone.dart';

class AdminAccountScreenController extends GetxController {
  static AdminAccountScreenController get instance => Get.find();
  final Rx<XFile?> profileImage = Rx<XFile?>(null);
  final Rxn<ImageProvider> profileMemoryImage = Rxn<ImageProvider>(null);
  final isProfileImageLoaded = false.obs;
  final isProfileImageChanged = false.obs;
  final picker = ImagePicker();
  late final FirebaseStorage fireStorage;
  late final String userId;
  late final User currentUser;
  late final EmployeeModel userInfo;
  late final AuthenticationRepository authRep;
  final RxInt chosenProfileOption = 0.obs;
  final gender = ''.obs;

  @override
  void onInit() async {
    authRep = AuthenticationRepository.instance;
    fireStorage = FirebaseStorage.instance;
    currentUser = authRep.fireUser.value!;
    userInfo = authRep.employeeInfo!;
    userId = currentUser.uid;
    loadProfileImage();
    super.onInit();
  }

  @override
  void onReady() {
    //
    super.onReady();
  }

  void loadProfileImage() async {
    try {
      final profileImageUrl = authRep.employeeInfo!.profileImageUrl;
      if (profileImageUrl.trim().isNotEmpty) {
        final response = await http.get(Uri.parse(profileImageUrl));
        if (response.statusCode == 200) {
          final imageBytes = response.bodyBytes;
          profileMemoryImage.value = MemoryImage(imageBytes);
          if (kDebugMode) AppInit.logger.i('Profile image loaded successfully');
        } else {
          if (kDebugMode) AppInit.logger.e('Failed to load profile image');
        }
      } else {
        if (kDebugMode) AppInit.logger.e('User doesn\'t have a profile image');
      }
      isProfileImageLoaded.value = true;
    } on FirebaseException catch (error) {
      if (kDebugMode) AppInit.logger.e(error.toString());
      isProfileImageLoaded.value = true;
    } catch (e) {
      if (kDebugMode) AppInit.logger.e(e.toString());
      isProfileImageLoaded.value = true;
    }
  }

  Future<void> pickProfilePic({required bool isPhone}) async {
    isPhone ? RegularBottomSheet.hideBottomSheet() : Get.back();
    final addedImage = await picker.pickImage(source: ImageSource.gallery);
    if (addedImage != null) {
      profileImage.value = addedImage;
      showLoadingScreen();
      final saveStatus = await saveProfileImage();
      hideLoadingScreen();
      if (saveStatus == FunctionStatus.success) {
        isProfileImageChanged.value = true;
        showSnackBar(
            text: 'profileImageChangeSuccess'.tr,
            snackBarType: SnackBarType.success);
      } else {
        showSnackBar(
            text: 'profileImageChangeFail'.tr,
            snackBarType: SnackBarType.error);
      }
    }
  }

  Future<void> captureProfilePic({required bool isPhone}) async {
    isPhone ? RegularBottomSheet.hideBottomSheet() : Get.back();
    if (await handleCameraPermission()) {
      final addedImage = await picker.pickImage(source: ImageSource.camera);
      if (addedImage != null) {
        profileImage.value = addedImage;
        showLoadingScreen();
        final saveStatus = await saveProfileImage();
        hideLoadingScreen();
        if (saveStatus == FunctionStatus.success) {
          isProfileImageChanged.value = true;
          showSnackBar(
              text: 'profileImageChangeSuccess'.tr,
              snackBarType: SnackBarType.success);
        } else {
          showSnackBar(
              text: 'profileImageChangeFail'.tr,
              snackBarType: SnackBarType.error);
        }
      }
    }
  }

  Future<FunctionStatus> saveProfileImage() async {
    try {
      final File file = File(profileImage.value!.path);
      final String fileName = 'users/$userId/profilePic';
      final Reference storageRef =
          FirebaseStorage.instance.ref().child(fileName);
      final UploadTask uploadTask = storageRef.putFile(file);
      await uploadTask;
      final String downloadUrl = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('employees')
          .doc(userId)
          .update({'profileImageUrl': downloadUrl});
      isProfileImageChanged.value = false;
      return FunctionStatus.success;
    } on FirebaseException catch (e) {
      AppInit.logger.e("An unexpected error occurred: ${e.message}");
    } catch (e) {
      AppInit.logger.e("An unexpected error occurred: $e");
    }
    return FunctionStatus.failure;
  }

  void onEditProfileTap({required bool isPhone}) {
    if (isPhone) {
      RegularBottomSheet.showRegularBottomSheet(
        PhotoSelectPhone(
          headerText: 'choosePicMethod'.tr,
          onCapturePhotoPress: () => captureProfilePic(isPhone: isPhone),
          onChoosePhotoPress: () => pickProfilePic(isPhone: isPhone),
        ),
      );
    } else {
      showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return PhotoSelect(
            headerText: 'choosePicMethod'.tr,
            onCapturePhotoPress: () => captureProfilePic(isPhone: isPhone),
            onChoosePhotoPress: () => pickProfilePic(isPhone: isPhone),
          );
        },
      );
    }
  }

  void onAccountOptionTap(int index, bool isPhone) {
    if (index == 3) {
      logoutDialogue();
    } else if (index == 2) {
      displayChangeLang();
    } else {
      if (isPhone) {
        Get.to(
            () => index == 0
                ? const PersonalInfoScreen()
                : const LoginPasswordScreenScreen(),
            transition: getPageTransition());
      } else {
        chosenProfileOption.value = index;
        if (Get.isRegistered<PersonalInfoFormController>()) {
          Get.delete<PersonalInfoFormController>();
        }
        if (Get.isRegistered<LoginPasswordFormController>()) {
          Get.delete<LoginPasswordFormController>();
        }
      }
    }
  }

  @override
  void onClose() async {
    //
    super.onClose();
  }
}
