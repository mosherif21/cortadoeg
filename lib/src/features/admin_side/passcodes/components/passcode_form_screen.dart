import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/admin_side/passcodes/components/passcode_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/back_button.dart';
import '../controllers/passcodes_screen_controller.dart';

class PasscodeFormScreen extends StatelessWidget {
  const PasscodeFormScreen({super.key, required this.controller});
  final PasscodesScreenController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RegularBackButton(padding: 0),
        elevation: 0,
        centerTitle: true,
        title: AutoSizeText(
          'passcodeOption${controller.chosenPasscodeOption.value + 1}'.tr,
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          maxLines: 1,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: PasscodeForm(controller: controller),
    );
  }
}
