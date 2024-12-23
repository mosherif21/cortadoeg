import 'package:cortadoeg/src/authentication/models.dart';
import 'package:cortadoeg/src/constants/enums.dart';
import 'package:cortadoeg/src/features/authentication/screens/auth_screen.dart';
import 'package:cortadoeg/src/features/cashier_side/account/components/photo_select.dart';
import 'package:cortadoeg/src/general/app_init.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../authentication/authentication_repository.dart';
import '../../../../general/common_widgets/regular_bottom_sheet.dart';
import '../../../../general/general_functions.dart';
import '../components/photo_select_phone.dart';

class AccountScreenController extends GetxController {
  static AccountScreenController get instance => Get.find();
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
      final userStorageRef = fireStorage.ref().child('users/$userId');
      final imageData = await userStorageRef.child('profilePic').getData();
      if (imageData != null) {
        profileMemoryImage.value = MemoryImage(imageData);
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
      isProfileImageChanged.value = true;
    }
  }

  Future<void> captureProfilePic({required bool isPhone}) async {
    isPhone ? RegularBottomSheet.hideBottomSheet() : Get.back();
    if (await handleCameraPermission()) {
      final addedImage = await picker.pickImage(source: ImageSource.camera);
      if (addedImage != null) {
        profileImage.value = addedImage;
        isProfileImageChanged.value = true;
      }
    }
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

  void logout() async {
    showLoadingScreen();
    final logoutStatus =
        await AuthenticationRepository.instance.logoutAuthUser();
    hideLoadingScreen();
    if (logoutStatus == FunctionStatus.success) {
      Get.offAll(() => const AuthenticationScreen());
    } else {
      showSnackBar(text: 'logoutFailed'.tr, snackBarType: SnackBarType.error);
    }
  }

  void onAccountOptionTap(int index) =>
      index == 2 ? logout() : chosenProfileOption.value = index;

  @override
  void onClose() async {
    //
    super.onClose();
  }
}
