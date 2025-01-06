import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/cashier_side/account/components/login_password_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/back_button.dart';

class LoginPasswordScreenScreen extends StatelessWidget {
  const LoginPasswordScreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const RegularBackButton(padding: 0),
        elevation: 0,
        centerTitle: true,
        title: AutoSizeText(
          'accountOption2'.tr,
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          maxLines: 1,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: const LoginPasswordForm(),
    );
  }
}
