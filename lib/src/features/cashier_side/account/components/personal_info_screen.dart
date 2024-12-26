import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/cashier_side/account/components/personal_info_form.dart';
import 'package:cortadoeg/src/features/cashier_side/account/controllers/personal_info_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../general/common_widgets/back_button.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (pop) => Get.delete<PersonalInfoFormController>(),
      child: Scaffold(
        appBar: AppBar(
          leading: const RegularBackButton(padding: 0),
          elevation: 0,
          centerTitle: true,
          title: AutoSizeText(
            'personalInformation'.tr,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
            maxLines: 1,
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: const PersonalInfoForm(),
      ),
    );
  }
}
