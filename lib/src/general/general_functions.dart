import 'dart:convert';
import 'dart:isolate';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortadoeg/src/general/shared_preferences_functions.dart';
import 'package:cortadoeg/src/general/validation_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_network/flutter_esc_pos_network.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ping_discover_network_forked/ping_discover_network_forked.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sweetsheet/sweetsheet.dart';
import 'package:url_launcher/url_launcher.dart';

import '../authentication/authentication_repository.dart';
import '../constants/assets_strings.dart';
import '../constants/enums.dart';
import '../features/authentication/screens/auth_screen.dart';
import '../features/cashier_side/main_screen/components/models.dart';
import '../features/cashier_side/orders/components/models.dart';
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
        child: Lottie.asset(
          kLoadingCoffeeAnim,
          height: height * 0.3,
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

void hideLoadingScreen() {
  Get.back();
}

Widget alignHorizontalWidget({required Widget child}) {
  return Align(
    alignment: isLangEnglish() ? Alignment.centerLeft : Alignment.centerRight,
    child: child,
  );
}

void closeKeyboard(BuildContext context) {
  FocusScopeNode currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    currentFocus.unfocus();
  }
}

String translateArabicToEnglish(String arabicNumber) {
  const arabicToEnglishMap = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  return arabicNumber.split('').map((char) {
    return arabicToEnglishMap[char] ??
        char; // Replace if found, otherwise keep the same
  }).join();
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

Future<FunctionStatus> openDrawerPrinter() async {
  final capabilitiesContent = await rootBundle
      .loadString('packages/flutter_esc_pos_utils/resources/capabilities.json');
  final ReceivePort receivePort = ReceivePort();
  await Isolate.spawn(openDrawerIsolate, {
    'capabilitiesContent': capabilitiesContent,
    'sendPort': receivePort.sendPort
  });
  final resultFromIsolate = await receivePort.first;
  return (resultFromIsolate as String).compareTo('success') == 0
      ? FunctionStatus.success
      : FunctionStatus.failure;
}

void openDrawerIsolate(Map<String, dynamic> data) async {
  final SendPort sendPort = data['sendPort'];
  final String capabilitiesContent = data['capabilitiesContent'];
  final resultStatus =
      await openDrawer(capabilitiesContent: capabilitiesContent);
  sendPort.send(resultStatus == FunctionStatus.success ? 'success' : 'failure');
}

Future<FunctionStatus> sendNotification({
  required String employeeId,
  required String orderNumber,
  required NotificationType notificationType,
}) async {
  final url = Uri.parse('https://sendnotification-e7icdbybjq-uc.a.run.app');
  final headers = {'Content-Type': 'application/json'};
  final body = json.encode({
    'employeeId': employeeId,
    'orderNumber': orderNumber,
    'notificationType': notificationType.name,
  });
  try {
    final response = await post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      if (kDebugMode) {
        AppInit.logger.i(
            'Notifications sent with type: $notificationType and response: ${response.body}');
      }
      return FunctionStatus.success;
    } else {
      if (kDebugMode) {
        AppInit.logger.e('Notifications send failed');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      AppInit.logger.e('Notifications send failed ${e.toString()}');
    }
  }
  return FunctionStatus.failure;
}

Future<FunctionStatus> chargeOrderPrinter(
    {required OrderModel order, required bool openDrawer}) async {
  final ByteData data = await rootBundle.load(kLogoImage);
  final capabilitiesContent = await rootBundle
      .loadString('packages/flutter_esc_pos_utils/resources/capabilities.json');
  final logoBytes = data.buffer.asUint8List();
  final ReceivePort receivePort = ReceivePort();
  final receiptOrderItems = order.items
      .map((item) => {
            'name': '${item.name} - ${item.selectedSize.name}',
            'qty': item.quantity,
            'price': item.price,
          })
      .toList();
  await Isolate.spawn(chargeOrderIsolate, {
    'sendPort': receivePort.sendPort,
    'orderValue': order,
    'capabilitiesContent': capabilitiesContent,
    'logoBytes': logoBytes,
    'openDrawer': openDrawer,
    'receiptOrderItems': receiptOrderItems,
    'orderNumber': order.orderNumber,
    'employeeName': order.employeeName,
    'orderId': order.orderId,
    'discountAmount': order.discountAmount,
    'subtotalAmount': order.subtotalAmount,
    'taxTotalAmount': order.taxTotalAmount,
    'totalAmount': order.totalAmount,
    'orderTime': order.timestamp.toDate(),
  });
  final resultFromIsolate = await receivePort.first;
  return (resultFromIsolate as String).compareTo('success') == 0
      ? FunctionStatus.success
      : FunctionStatus.failure;
}

void chargeOrderIsolate(Map<String, dynamic> data) async {
  final SendPort sendPort = data['sendPort'];
  final String capabilitiesContent = data['capabilitiesContent'];
  final Uint8List logoBytes = data['logoBytes'];
  final bool openDrawer = data['openDrawer'];
  final List<Map<String, dynamic>> receiptOrderItems =
      data['receiptOrderItems'];
  final int orderNumber = data['orderNumber'];
  final String employeeName = data['employeeName'];
  final String orderId = data['orderId'];
  final double discountAmount = data['discountAmount'];
  final double subtotalAmount = data['subtotalAmount'];
  final double taxTotalAmount = data['taxTotalAmount'];
  final double totalAmount = data['totalAmount'];
  final DateTime orderTime = data['orderTime'];
  final resultStatus = await printReceipt(
    logoBytes: logoBytes,
    capabilitiesContent: capabilitiesContent,
    openDrawer: openDrawer,
    receiptOrderItems: receiptOrderItems,
    orderNumber: orderNumber.toString(),
    employeeName: employeeName,
    orderId: orderId,
    discountAmount: discountAmount,
    subtotalAmount: subtotalAmount,
    taxTotalAmount: taxTotalAmount,
    totalAmount: totalAmount,
    orderTime: orderTime,
  );
  sendPort.send(resultStatus == FunctionStatus.success ? 'success' : 'failure');
}

Future<FunctionStatus> printReceipt({
  required List<Map<String, dynamic>> receiptOrderItems,
  required String orderNumber,
  required String employeeName,
  required String orderId,
  required double discountAmount,
  required double subtotalAmount,
  required double taxTotalAmount,
  required double totalAmount,
  required DateTime orderTime,
  required String capabilitiesContent,
  required Uint8List logoBytes,
  required bool openDrawer,
}) async {
  try {
    final receiptBytes = await generateReceiptBytes(
      cafeName: 'Cortado Egypt - Louran Branch',
      slogan: 'Fix What Others Have Ruined',
      address: '50 Al Akbal Street, Louran, Alexandria EG',
      phone: '01111241552',
      website: 'www.cortadoeg.com',
      orderNumber: orderNumber,
      printedAt: DateTime.now(),
      orderTime: orderTime,
      creator: employeeName,
      orderItems: receiptOrderItems,
      discount: discountAmount,
      taxTotalAmount: taxTotalAmount,
      subtotal: subtotalAmount,
      total: totalAmount,
      qrData: 'https://www.cortadoeg.com',
      logoBytes: logoBytes,
      capabilitiesContent: capabilitiesContent,
      openDrawer: openDrawer,
      orderId: orderId,
      taxId: '648-394-425',
    );
    const printerIp = '192.168.1.8';
    //await getPrinterIP();

    // if (printerIp == null) {
    //   return FunctionStatus.failure;
    // }
    final printer = PrinterNetworkManager(printerIp);
    final PosPrintResult result = await printer.connect();

    if (result == PosPrintResult.success) {
      await printer.printTicket(receiptBytes);
      printer.disconnect();

      if (kDebugMode) {
        AppInit.logger.i('Receipt printed Successfully');
      }
      return FunctionStatus.success;
    } else {
      if (kDebugMode) {
        AppInit.logger.e('Failed to connect to printer');
      }
      return FunctionStatus.failure;
    }
    // final printer = PrinterNetworkManager('192.168.1.8');
    // final PosPrintResult result = await printer.connect();
    // if (result == PosPrintResult.success) {
    //   await printer.printTicket(receiptBytes);
    //   printer.disconnect();
    //   if (kDebugMode) {
    //     AppInit.logger.i('Receipt printed Successfully');
    //   }
    //   return FunctionStatus.success;
    // } else {
    //   if (kDebugMode) {
    //     AppInit.logger.e('Failed to connect to printer');
    //   }
    //   return FunctionStatus.failure;
    // }
  } catch (e) {
    if (kDebugMode) {
      AppInit.logger.e(e.toString());
    }
    return FunctionStatus.failure;
  }
}

Future<String?> getPrinterIP() async {
  try {
    const subnet = '192.168.1';
    const port = 9100;
    final stream = NetworkAnalyzer.discover2(
      '$subnet.0',
      port,
      timeout: const Duration(seconds: 5),
    );

    await for (final NetworkAddress address in stream) {
      if (address.exists) {
        if (kDebugMode) {
          AppInit.logger.i('Printer found at ${address.ip}');
        }
        return address.ip;
      }
    }
    if (kDebugMode) {
      AppInit.logger.e('No printers found on the network.');
    }
    return null;
  } catch (e) {
    if (kDebugMode) {
      AppInit.logger.e('Error during printer discovery: $e');
    }
    return null;
  }
}

Future<List<int>> generateReceiptBytes({
  required String cafeName,
  required String slogan,
  required String address,
  required String phone,
  required String orderId,
  required String taxId,
  required String website,
  required String orderNumber,
  required DateTime printedAt,
  required DateTime orderTime,
  required String creator,
  required List<Map<String, dynamic>> orderItems,
  required double discount,
  required double subtotal,
  required double taxTotalAmount,
  required double total,
  required String qrData,
  required Uint8List logoBytes,
  required String capabilitiesContent,
  required bool openDrawer,
}) async {
  final profile =
      await CapabilityProfile.load(capabilitiesContent: capabilitiesContent);
  final generator = Generator(PaperSize.mm80, profile);
  List<int> bytes = [];
  if (openDrawer) {
    bytes += generator.drawer();
  }
  final image = decodeImage(logoBytes);
  if (image != null) {
    final resizedImage = copyResize(image, width: 384);
    bytes += generator.image(resizedImage);
  }
  bytes += generator.feed(1);

  bytes += generator.text(cafeName,
      styles: const PosStyles(
          align: PosAlign.center, bold: true, fontType: PosFontType.fontA));
  bytes += generator.text('Free Palestine',
      styles: const PosStyles(
          align: PosAlign.center, bold: true, fontType: PosFontType.fontA));
  bytes += generator.feed(1);

  bytes += generator.text(address,
      styles: const PosStyles(
          align: PosAlign.center, bold: true, fontType: PosFontType.fontA));
  bytes += generator.text('Tel: $phone',
      styles: const PosStyles(
          align: PosAlign.center, bold: true, fontType: PosFontType.fontA));
  bytes += generator.text('Visit us: $website',
      styles: const PosStyles(
          align: PosAlign.center, bold: true, fontType: PosFontType.fontA));
  bytes += generator.feed(1);

  bytes += generator.text('Order# $orderNumber',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        fontType: PosFontType.fontA,
        width: PosTextSize.size2,
        height: PosTextSize.size2,
      ));
  bytes += generator.feed(1);
  bytes += generator.text(
      'Printed At: ${DateFormat('yyyy/MM/dd hh:mm:ss a').format(printedAt)}',
      styles: const PosStyles(
          align: PosAlign.left, bold: true, fontType: PosFontType.fontA));
  bytes += generator.text(
      'Order Time: ${DateFormat('yyyy/MM/dd hh:mm:ss a').format(orderTime)}',
      styles: const PosStyles(
          align: PosAlign.left, bold: true, fontType: PosFontType.fontA));
  bytes += generator.text('Creator: $creator',
      styles: const PosStyles(
          align: PosAlign.left, bold: true, fontType: PosFontType.fontA));
  bytes += generator.hr(); // Horizontal line

  bytes += generator.row([
    PosColumn(
        text: 'QTY',
        width: 2,
        styles: const PosStyles(
            align: PosAlign.left, bold: true, fontType: PosFontType.fontA)),
    PosColumn(
        text: 'ITEM',
        width: 6,
        styles: const PosStyles(
            align: PosAlign.left, bold: true, fontType: PosFontType.fontA)),
    PosColumn(
        text: 'PRICE',
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right, bold: true, fontType: PosFontType.fontA)),
  ]);
  bytes += generator.hr();

  for (var item in orderItems) {
    bytes += generator.row([
      PosColumn(
        text: '${item['qty']}',
        width: 2,
        styles: const PosStyles(
            align: PosAlign.left, bold: true, fontType: PosFontType.fontA),
      ),
      PosColumn(
        text: item['name'],
        width: 6,
        styles: const PosStyles(
            align: PosAlign.left, bold: true, fontType: PosFontType.fontA),
      ),
      PosColumn(
        text: 'EGP ${item['price'].toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right, bold: true, fontType: PosFontType.fontA),
      ),
    ]);
  }
  bytes += generator.hr();
  if (discount > 0 || taxTotalAmount > 0) {
    bytes += generator.row([
      PosColumn(
        text: 'Subtotal:',
        width: 8,
        styles: const PosStyles(
            align: PosAlign.right, bold: true, fontType: PosFontType.fontA),
      ),
      PosColumn(
        text: 'EGP ${subtotal.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(
            align: PosAlign.right, bold: true, fontType: PosFontType.fontA),
      ),
    ]);
    if (taxTotalAmount > 0) {
      bytes += generator.row([
        PosColumn(
          text: '14% VAT:',
          width: 8,
          styles: const PosStyles(
              align: PosAlign.right, bold: true, fontType: PosFontType.fontA),
        ),
        PosColumn(
          text: 'EGP ${taxTotalAmount.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(
              align: PosAlign.right, bold: true, fontType: PosFontType.fontA),
        ),
      ]);
    }
    if (discount > 0) {
      bytes += generator.row([
        PosColumn(
          text: 'Discount:',
          width: 8,
          styles: const PosStyles(
              align: PosAlign.right, bold: true, fontType: PosFontType.fontA),
        ),
        PosColumn(
          text: 'EGP ${discount.toStringAsFixed(2)}',
          width: 4,
          styles: const PosStyles(
              align: PosAlign.right, bold: true, fontType: PosFontType.fontA),
        ),
      ]);
    }
  }
  bytes += generator.row([
    PosColumn(
      text: 'Total:',
      width: 8,
      styles: const PosStyles(
          align: PosAlign.right, bold: true, fontType: PosFontType.fontA),
    ),
    PosColumn(
      text: 'EGP ${total.toStringAsFixed(2)}',
      width: 4,
      styles: const PosStyles(
          align: PosAlign.right, bold: true, fontType: PosFontType.fontA),
    ),
  ]);

  bytes += generator.feed(1);
  bytes += generator.text(slogan,
      styles: const PosStyles(
          align: PosAlign.center, bold: true, fontType: PosFontType.fontA));
  bytes += generator.feed(1);
  bytes += generator.qrcode(qrData, size: QRSize.size4);
  bytes += generator.text('Tax-ID $taxId',
      styles: const PosStyles(
          align: PosAlign.center, bold: true, fontType: PosFontType.fontA));
  bytes += generator.feed(1);

  bytes += generator.cut();
  return bytes;
}

Future<FunctionStatus> openDrawer({required String capabilitiesContent}) async {
  try {
    final profile =
        await CapabilityProfile.load(capabilitiesContent: capabilitiesContent);
    final generator = Generator(PaperSize.mm80, profile);
    List<int> openDrawerBytes = [];
    openDrawerBytes += generator.drawer();

    const printerIp = '192.168.1.8';
    //await getPrinterIP();

    // if (printerIp == null) {
    //   return FunctionStatus.failure;
    // }

    final printer = PrinterNetworkManager(printerIp);
    final PosPrintResult result = await printer.connect();

    if (result == PosPrintResult.success) {
      await printer.printTicket(openDrawerBytes);
      printer.disconnect();

      if (kDebugMode) {
        AppInit.logger.i('Cash drawer opened successfully Successfully');
      }
      return FunctionStatus.success;
    } else {
      if (kDebugMode) {
        AppInit.logger.e('Failed to connect to printer');
      }
      return FunctionStatus.failure;
    }
  } catch (e) {
    if (kDebugMode) {
      AppInit.logger.e(e.toString());
    }
    return FunctionStatus.failure;
  }
}

Future<FunctionStatus> printCustodyReceipt({
  required CustodyReport custody,
}) async {
  final ByteData data = await rootBundle.load(kLogoImage);
  final capabilitiesContent = await rootBundle
      .loadString('packages/flutter_esc_pos_utils/resources/capabilities.json');
  final logoBytes = data.buffer.asUint8List();
  final ReceivePort receivePort = ReceivePort();

  await Isolate.spawn(printCustodyIsolate, {
    'sendPort': receivePort.sendPort,
    'custody': custody,
    'capabilitiesContent': capabilitiesContent,
    'logoBytes': logoBytes,
  });

  final resultFromIsolate = await receivePort.first;
  return (resultFromIsolate as String).compareTo('success') == 0
      ? FunctionStatus.success
      : FunctionStatus.failure;
}

void printCustodyIsolate(Map<String, dynamic> data) async {
  final SendPort sendPort = data['sendPort'];
  final CustodyReport custody = data['custody'];
  final String capabilitiesContent = data['capabilitiesContent'];
  final Uint8List logoBytes = data['logoBytes'];

  final resultStatus = await generateAndPrintCustodyReceipt(
    custody: custody,
    logoBytes: logoBytes,
    capabilitiesContent: capabilitiesContent,
  );
  sendPort.send(resultStatus == FunctionStatus.success ? 'success' : 'failure');
}

Future<FunctionStatus> generateAndPrintCustodyReceipt({
  required CustodyReport custody,
  required Uint8List logoBytes,
  required String capabilitiesContent,
}) async {
  try {
    final receiptBytes = await generateCustodyReceiptBytes(
      custody: custody,
      logoBytes: logoBytes,
      capabilitiesContent: capabilitiesContent,
    );
    const printerIp = '192.168.1.8';
    //await getPrinterIP();

    // if (printerIp == null) {
    //   return FunctionStatus.failure;
    // }
    final printer = PrinterNetworkManager(printerIp);
    final PosPrintResult result = await printer.connect();
    if (result == PosPrintResult.success) {
      await printer.printTicket(receiptBytes);
      printer.disconnect();

      if (kDebugMode) {
        AppInit.logger.i('Custody shift receipt printed Successfully');
      }
      return FunctionStatus.success;
    } else {
      if (kDebugMode) {
        AppInit.logger.e('Failed to connect to printer');
      }
      return FunctionStatus.failure;
    }
  } catch (e) {
    return FunctionStatus.failure;
  }
}

Future<List<int>> generateCustodyReceiptBytes({
  required CustodyReport custody,
  required Uint8List logoBytes,
  required String capabilitiesContent,
}) async {
  final profile =
      await CapabilityProfile.load(capabilitiesContent: capabilitiesContent);
  final generator = Generator(PaperSize.mm80, profile);
  List<int> bytes = [];

  // Add logo
  final image = decodeImage(logoBytes);
  if (image != null) {
    final resizedImage = copyResize(image, width: 384);
    bytes += generator.image(resizedImage);
  }
  bytes += generator.feed(1);

  // Header
  bytes += generator.text('Cortado Egypt - Louran Branch',
      styles: const PosStyles(align: PosAlign.center, bold: true));
  bytes += generator.text('Fix What Others Have Ruined',
      styles: const PosStyles(align: PosAlign.center));
  bytes += generator.hr();

  // Shift Information
  bytes += generator.text('Custody Shift ID: ${custody.id}',
      styles: const PosStyles(align: PosAlign.left));
  bytes += generator.text(
      'Opening: ${DateFormat('yyyy/MM/dd hh:mm:ss a').format(custody.openingTime.toDate())}',
      styles: const PosStyles(align: PosAlign.left));
  bytes += generator.text(
      'Closing: ${DateFormat('yyyy/MM/dd hh:mm:ss a').format(custody.closingTime.toDate())}',
      styles: const PosStyles(align: PosAlign.left));
  bytes += generator.hr();

  // Financial Details
  bytes += generator.row([
    PosColumn(
        text: 'Opening Amount:',
        width: 8,
        styles: const PosStyles(align: PosAlign.left)),
    PosColumn(
        text: 'EGP ${custody.openingAmount.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right)),
  ]);
  bytes += generator.row([
    PosColumn(
        text: 'Cash Payments:',
        width: 8,
        styles: const PosStyles(align: PosAlign.left)),
    PosColumn(
        text: 'EGP ${custody.cashPaymentsNet.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right)),
  ]);
  bytes += generator.row([
    PosColumn(
        text: 'Pay-Ins:',
        width: 8,
        styles: const PosStyles(align: PosAlign.left)),
    PosColumn(
        text: 'EGP ${custody.totalPayIns.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right)),
  ]);
  bytes += generator.row([
    PosColumn(
        text: 'Pay-Outs:',
        width: 8,
        styles: const PosStyles(align: PosAlign.left)),
    PosColumn(
        text: 'EGP ${custody.totalPayOuts.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right)),
  ]);
  bytes += generator.row([
    PosColumn(
        text: 'Cash Drops:',
        width: 8,
        styles: const PosStyles(align: PosAlign.left)),
    PosColumn(
        text: 'EGP ${custody.cashDrop.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right)),
  ]);

  bytes += generator.hr();

  // Drawer Summary
  bytes += generator.row([
    PosColumn(
        text: 'Expected Drawer:',
        width: 8,
        styles: const PosStyles(align: PosAlign.left)),
    PosColumn(
        text: 'EGP ${custody.expectedDrawerMoney.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right)),
  ]);
  bytes += generator.row([
    PosColumn(
        text: 'Actual Drawer:',
        width: 8,
        styles: const PosStyles(align: PosAlign.left)),
    PosColumn(
        text: 'EGP ${custody.closingAmount.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right)),
  ]);
  bytes += generator.row([
    PosColumn(
        text: 'Difference:',
        width: 8,
        styles: const PosStyles(align: PosAlign.left)),
    PosColumn(
        text: 'EGP ${custody.difference.toStringAsFixed(2)}',
        width: 4,
        styles: const PosStyles(align: PosAlign.right)),
  ]);

  // Drawer Open Count
  bytes += generator.text(
      'Drawer opened ${custody.drawerOpenCount} times manually.',
      styles: const PosStyles(align: PosAlign.left));
  bytes += generator.hr();

  // Footer
  bytes += generator.text('Thank you for using Cortado!',
      styles: const PosStyles(align: PosAlign.center, bold: true));
  bytes += generator.feed(1);
  bytes += generator.cut();

  return bytes;
}

Transition getPageTransition() {
  final context = Get.context;
  if (context != null) {
    final screenType = GetScreenType(context);
    return !screenType.isPhone
        ? Transition.downToUp
        : AppInit.currentLanguage == Language.english
            ? Transition.rightToLeft
            : Transition.leftToRight;
  }

  return AppInit.currentLanguage == Language.english
      ? Transition.rightToLeft
      : Transition.leftToRight;
}

void displayChangeLang() {
  if (Get.context != null) {
    final screenType = GetScreenType(Get.context!);
    screenType.isPhone
        ? showRegularBottomSheet(
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

String getOrderTime(DateTime dateTime) {
  return DateFormat('hh:mm a', isLangEnglish() ? 'en_US' : 'ar_SA')
      .format(dateTime);
}

String getOrderDate(DateTime dateTime) {
  return DateFormat('dd/MM', isLangEnglish() ? 'en_US' : 'ar_SA')
      .format(dateTime);
}

double roundToNearestHalfOrWhole(double value) {
  final rounded = value.round(); // Round to nearest whole number
  final diff = value - rounded; // Find the difference

  if (diff.abs() >= 0.1 && diff.abs() < 0.75) {
    return rounded + (diff.isNegative ? -0.5 : 0.5);
  }
  return rounded.toDouble();
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
        color: CustomSheetColor(
            main: Colors.black, accent: Colors.black, icon: Colors.white),
      );
    }
  } catch (err) {
    if (kDebugMode) {
      AppInit.logger.e(err.toString());
    }
  }

  return false;
}

void logoutDialogue() => displayAlertDialog(
      title: 'logout'.tr,
      body: 'logoutConfirm'.tr,
      positiveButtonText: 'yes'.tr,
      negativeButtonText: 'no'.tr,
      positiveButtonOnPressed: () => logout(),
      negativeButtonOnPressed: () => Get.back(),
      mainIcon: Icons.logout,
      color: CustomSheetColor(
          main: Colors.black, accent: Colors.black, icon: Colors.white),
    );
void logout() async {
  showLoadingScreen();
  final logoutStatus = await AuthenticationRepository.instance.logoutAuthUser();
  hideLoadingScreen();
  if (logoutStatus == FunctionStatus.success) {
    Get.offAll(() => const AuthenticationScreen());
  } else {
    showSnackBar(text: 'logoutFailed'.tr, snackBarType: SnackBarType.error);
  }
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

String formatDateTime(Timestamp timestamp) {
  DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
  DateFormat formatter =
      DateFormat('MMM d y hh:mm a', isLangEnglish() ? 'en_US' : 'ar_SA');
  return formatter.format(dateTime);
}

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

bool isNumeric(String str) {
  if (str.isEmpty) {
    showSnackBar(text: 'textEmpty'.tr, snackBarType: SnackBarType.error);
    return false;
  } else if (double.tryParse(str) == null) {
    showSnackBar(text: 'enterNumber'.tr, snackBarType: SnackBarType.error);
    return false;
  } else {
    return true;
  }
}
