import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/cashier_side/account/controllers/personal_info_form_controller.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../general/validation_functions.dart';

class PersonalInfoForm extends StatelessWidget {
  const PersonalInfoForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PersonalInfoFormController());
    final screenType = GetScreenType(context);
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenType.isPhone ? 16 : 50, horizontal: 25),
      child: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!screenType.isPhone)
                Text(
                  'personalInformation'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 16),
              AutoSizeText(
                'enterGender'.tr,
                maxLines: 1,
                style: TextStyle(
                  fontSize: screenType.isPhone ? 18 : 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Obx(
                    () => Row(
                      children: [
                        Text('male'.tr),
                        Radio<String>(
                          activeColor: Colors.black,
                          hoverColor: Colors.black,
                          focusColor: Colors.black,
                          fillColor: const WidgetStatePropertyAll(Colors.black),
                          value: 'male',
                          groupValue: controller.gender.value,
                          onChanged: (value) {
                            if (value != null) {
                              controller.gender.value = value;
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        Text('female'.tr),
                        Radio<String>(
                          activeColor: Colors.black,
                          hoverColor: Colors.black,
                          focusColor: Colors.black,
                          fillColor: const WidgetStatePropertyAll(Colors.black),
                          value: 'female',
                          groupValue: controller.gender.value,
                          onChanged: (value) {
                            if (value != null) {
                              controller.gender.value = value;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          'firstName'.tr,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: screenType.isPhone ? 18 : 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100)
                            ],
                            controller: controller.firstNameController,
                            keyboardType: TextInputType.name,
                            cursorColor: Colors.black,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                            decoration: InputDecoration(
                              hintStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: 'enterFirstName'.tr,
                            ),
                            validator: validateTextOnly,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          'lastName'.tr,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: screenType.isPhone ? 18 : 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100)
                            ],
                            controller: controller.lastNameController,
                            keyboardType: TextInputType.name,
                            cursorColor: Colors.black,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                            decoration: InputDecoration(
                              hintStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: 'enterLastName'.tr,
                            ),
                            validator: validateTextOnly,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    'email'.tr,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: screenType.isPhone ? 18 : 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => TextFormField(
                              enabled: false,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100)
                              ],
                              initialValue: controller.authRep.userEmail.value,
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: Colors.black,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                              decoration: InputDecoration(
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: true,
                                fillColor: Colors.grey[200],
                                hintText: 'enterEmail'.tr,
                              ),
                              validator: validateEmail,
                            ),
                          ),
                        ),
                        Obx(
                          () => Material(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.transparent,
                            child: InkWell(
                              splashFactory: InkSparkle.splashFactory,
                              borderRadius: BorderRadius.circular(15),
                              onTap:
                                  !controller.authRep.isEmailVerified.value &&
                                          !controller.verificationSent.value
                                      ? () => controller.verifyEmail()
                                      : null,
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  children: [
                                    Icon(
                                      controller.authRep.isEmailVerified.value
                                          ? Icons.verified_rounded
                                          : controller.verificationSent.value
                                              ? Icons.mark_email_read_sharp
                                              : Icons.cancel_rounded,
                                      color: controller
                                              .authRep.isEmailVerified.value
                                          ? Colors.green
                                          : controller.verificationSent.value
                                              ? Colors.grey
                                              : Colors.red,
                                    ),
                                    const SizedBox(width: 5),
                                    AutoSizeText(
                                      controller.authRep.isEmailVerified.value
                                          ? 'verified'.tr
                                          : controller.verificationSent.value
                                              ? 'verificationSent'.tr
                                              : 'verify'.tr,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: controller
                                                .authRep.isEmailVerified.value
                                            ? Colors.green
                                            : controller.verificationSent.value
                                                ? Colors.grey
                                                : Colors.red,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          'phoneNumber'.tr,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: screenType.isPhone ? 18 : 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextFormField(
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100)
                            ],
                            controller: controller.phoneController,
                            keyboardType: TextInputType.phone,
                            cursorColor: Colors.black,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                            decoration: InputDecoration(
                              hintStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: true,
                              fillColor: Colors.grey[200],
                              hintText: 'enterPhoneNumber'.tr,
                            ),
                            validator: validateNumbersOnly,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          'dateOfBirth'.tr,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: screenType.isPhone ? 18 : 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => controller.changeDateOfBirth(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              enabled: false,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(100)
                              ],
                              controller: controller.dobController,
                              keyboardType: TextInputType.name,
                              cursorColor: Colors.black,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                              decoration: InputDecoration(
                                suffixIcon:
                                    const Icon(Icons.date_range_rounded),
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: true,
                                fillColor: Colors.grey[200],
                                hintText: 'enterDateOfBirth'.tr,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: screenType.isPhone ? double.maxFinite : 400,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      overlayColor: Colors.grey,
                      surfaceTintColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () =>
                        controller.onSaveChanges(screenType.isPhone),
                    child: Text(
                      'saveChanges'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
