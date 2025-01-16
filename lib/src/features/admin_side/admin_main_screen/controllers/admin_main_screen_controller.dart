import 'dart:async';

import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/authentication/authentication_repository.dart';
import 'package:cortadoeg/src/authentication/models.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../../../general/app_init.dart';

class AdminMainScreenController extends GetxController {
  static AdminMainScreenController get instance => Get.find();
  late final SidebarXController barController;
  late final GlobalKey<ScaffoldState> homeScaffoldKey;
  late final PageController pageController;
  final navBarIndex = 0.obs;
  String editOrderPasscodeHash = '';
  String cancelOrderPasscodeHash = '';
  String manageDayShiftPasscodeHash = '';
  String openDrawerPasscodeHash = '';
  String finalizeOrdersPasscodeHash = '';
  String returnOrdersPasscodeHash = '';
  final RxBool navBarExtended = false.obs;
  final RxInt currentSelectedTransaction = 0.obs;
  late final StreamController<bool> verificationNotifier;
  final firestore = FirebaseFirestore.instance;

  final notificationsCount = 0.obs;
  late final StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      notificationCountStreamSubscription;

  @override
  void onInit() async {
    verificationNotifier = StreamController<bool>.broadcast();
    barController = SidebarXController(selectedIndex: 0, extended: true);
    pageController = PageController(initialPage: 0, keepPage: true);
    homeScaffoldKey = GlobalKey<ScaffoldState>();
    super.onInit();
  }

  @override
  void onReady() {
    barController.addListener(() {
      navBarExtended.value = barController.extended;
      final selectedNavIndex = barController.selectedIndex;
      navBarIndex.value = selectedNavIndex;
      pageController.jumpToPage(selectedNavIndex);
    });
    getPasscodesHashStream().listen((hashSnapshot) {
      if (hashSnapshot != null) {
        editOrderPasscodeHash = hashSnapshot['editOrderItemsHash']!.toString();
        cancelOrderPasscodeHash = hashSnapshot['cancelOrdersHash']!.toString();
        manageDayShiftPasscodeHash =
            hashSnapshot['manageDayShiftHash']!.toString();
        openDrawerPasscodeHash = hashSnapshot['openDrawerHash']!.toString();
        finalizeOrdersPasscodeHash =
            hashSnapshot['finalizeOrdersHash']!.toString();
        returnOrdersPasscodeHash = hashSnapshot['returnOrdersHash']!.toString();
      }
    });
    handleNotificationsPermission();
    listenForNotificationCount();
    super.onReady();
  }

  void onDrawerOpen() {
    barController.setExtended(true);
    homeScaffoldKey.currentState?.openDrawer();
  }

  void listenForNotificationCount() {
    try {
      final userId = AuthenticationRepository.instance.employeeInfo!.id;
      notificationCountStreamSubscription = FirebaseFirestore.instance
          .collection('notifications')
          .doc(userId)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          notificationsCount.value = snapshot.data()!['unseenCount'] as int;
        } else {
          notificationsCount.value = 0;
        }
      });
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    } catch (err) {
      if (kDebugMode) {
        AppInit.logger.e(err.toString());
      }
    }
  }

  // Future<FunctionStatus> saveEditOrderPasscode(String passcode) async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('passcodes')
  //         .doc('passcodes')
  //         .set({
  //       'editOrderItemsHash': BCrypt.hashpw(
  //           isLangEnglish() ? passcode : translateArabicToEnglish(passcode),
  //           BCrypt.gensalt()),
  //     }, SetOptions(merge: true));
  //     return FunctionStatus.success;
  //   } on FirebaseException catch (error) {
  //     if (kDebugMode) {
  //       AppInit.logger.e(error.toString());
  //     }
  //   } catch (err) {
  //     if (kDebugMode) {
  //       AppInit.logger.e(err.toString());
  //     }
  //   }
  //   return FunctionStatus.failure;
  // }

  Future<bool> showPassCodeScreen(
      {required BuildContext context,
      required PasscodeType passcodeType}) async {
    bool valid = false;
    await showDialog(
      useSafeArea: false,
      context: context,
      builder: (context) {
        return PasscodeScreen(
          digits: isLangEnglish()
              ? ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0']
              : ['١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩', '٠'],
          title: Text(
            'enterPasscode'.tr,
            style: const TextStyle(color: Colors.white, fontSize: 25),
          ),
          passwordEnteredCallback: (String enteredPasscode) {
            bool isValid = verifyPasscode(enteredPasscode, passcodeType);
            verificationNotifier.add(isValid);
          },
          cancelButton: Text(
            'cancel'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          isValidCallback: () => valid = true,
          cancelCallback: () => Get.back(),
          deleteButton: Text(
            'delete'.tr,
            style: const TextStyle(color: Colors.white),
          ),
          shouldTriggerVerification: verificationNotifier.stream,
        );
      },
    );
    return valid;
  }

  bool verifyPasscode(String inputPasscode, PasscodeType passcodeType) {
    return BCrypt.checkpw(
        isLangEnglish()
            ? inputPasscode
            : translateArabicToEnglish(inputPasscode),
        getPasscodeTypeHash(passcodeType));
  }

  String getPasscodeTypeHash(PasscodeType type) {
    switch (type) {
      case PasscodeType.editOrderItems:
        return editOrderPasscodeHash;
      case PasscodeType.cancelOrders:
        return cancelOrderPasscodeHash;
      case PasscodeType.manageDayShift:
        return manageDayShiftPasscodeHash;
      case PasscodeType.openDrawer:
        return openDrawerPasscodeHash;
      case PasscodeType.finalizeOrders:
        return finalizeOrdersPasscodeHash;
      case PasscodeType.returnOrders:
        return returnOrdersPasscodeHash;
    }
  }

  Stream<DocumentSnapshot?> getPasscodesHashStream() {
    return firestore
        .collection('passcodes')
        .doc('passcodes')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot;
      }
      return null;
    }).handleError((error) {
      if (kDebugMode) {
        AppInit.logger.e(error.toString());
      }
    });
  }

  String getPageTitle(int navBarIndex) {
    switch (navBarIndex) {
      case 0:
        return 'reports'.tr;
      case 1:
        return 'custodyShifts'.tr;
      case 2:
        return 'tables'.tr;
      case 3:
        return 'menuItems'.tr;
      case 4:
        return 'categories'.tr;
      case 5:
        return 'inventory'.tr;
      case 6:
        return 'customers'.tr;
      case 7:
        return 'employees'.tr;
      case 8:
        return 'passcodes'.tr;
      case 9:
        return 'account'.tr;
      default:
        return 'reports'.tr;
    }
  }

  @override
  void onClose() async {
    pageController.dispose();
    barController.dispose();
    notificationCountStreamSubscription?.cancel();
    super.onClose();
  }
}
