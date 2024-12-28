import 'package:auto_size_text/auto_size_text.dart';
import 'package:cortadoeg/src/features/authentication/components/emailChange/email_change_page.dart';
import 'package:cortadoeg/src/features/authentication/components/resetPassword/reset_password_page.dart';
import 'package:cortadoeg/src/features/cashier_side/account/controllers/login_password_form_controller.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../constants/assets_strings.dart';
import '../../../../general/common_widgets/link_account_button.dart';
import '../../../../general/validation_functions.dart';

class LoginPasswordForm extends StatelessWidget {
  const LoginPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginPasswordFormController());
    final screenType = GetScreenType(context);
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: screenType.isPhone ? 16 : 50, horizontal: 25),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!screenType.isPhone)
              Text(
                'accountOption2'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
                screenType.isPhone
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Container(
                              width: 300,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Obx(
                                () => TextFormField(
                                  enabled: false,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(100)
                                  ],
                                  initialValue:
                                      controller.authRep.userEmail.value,
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
                            const SizedBox(height: 10),
                            SizedBox(
                              width: isLangEnglish() ? 180 : 200,
                              child: Material(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.transparent,
                                child: InkWell(
                                  splashFactory: InkSparkle.splashFactory,
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () => Get.to(
                                      () => const EmailChangePage(),
                                      transition: getPageTransition()),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.email_rounded,
                                          size: 30,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 5),
                                        AutoSizeText(
                                          'changeEmail'.tr,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ])
                    : Row(
                        children: [
                          Container(
                            width: 300,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Obx(
                              () => TextFormField(
                                enabled: false,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                initialValue:
                                    controller.authRep.userEmail.value,
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
                          const SizedBox(width: 10),
                          Material(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.transparent,
                            child: InkWell(
                              splashFactory: InkSparkle.splashFactory,
                              borderRadius: BorderRadius.circular(15),
                              onTap: () => Get.to(() => const EmailChangePage(),
                                  transition: getPageTransition()),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.email_rounded,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 5),
                                    AutoSizeText(
                                      'changeEmail'.tr,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'password'.tr,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: screenType.isPhone ? 18 : 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                screenType.isPhone
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 300,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    enabled: false,
                                    textInputAction: TextInputAction.next,
                                    obscureText: true,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(100)
                                    ],
                                    initialValue: 'password',
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
                                      hintText: 'enterPassword'.tr,
                                    ),
                                    validator: validateEmail,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 200,
                            child: Material(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.transparent,
                              child: InkWell(
                                splashFactory: InkSparkle.splashFactory,
                                borderRadius: BorderRadius.circular(15),
                                onTap: () => Get.to(
                                    () => const ResetPasswordPage(),
                                    transition: getPageTransition()),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.key,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 5),
                                      AutoSizeText(
                                        'changePassword'.tr,
                                        maxLines: 1,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Container(
                            width: 300,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    enabled: false,
                                    textInputAction: TextInputAction.next,
                                    obscureText: true,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(100)
                                    ],
                                    initialValue: 'password',
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
                                      hintText: 'enterPassword'.tr,
                                    ),
                                    validator: validateEmail,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Material(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.transparent,
                            child: InkWell(
                              splashFactory: InkSparkle.splashFactory,
                              borderRadius: BorderRadius.circular(15),
                              onTap: () => Get.to(
                                  () => const ResetPasswordPage(),
                                  transition: getPageTransition()),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.key,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 5),
                                    AutoSizeText(
                                      'changePassword'.tr,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
            SizedBox(height: screenType.isPhone ? 15 : 30),
            Text(
              'signInSocialNetwork'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'linkSocialAccounts'.tr,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            screenType.isPhone
                ? Column(
                    children: [
                      Obx(
                        () => LinkAccountButton(
                          buttonText: controller.authRep.isGoogleLinked.value
                              ? 'changeGoogleAccount'.tr
                              : 'linkGoogleAccount'.tr,
                          imagePath: kGoogleImage,
                          onPressed: () => controller.authRep.linkWithGoogle(),
                        ),
                      ),
                      /*  const SizedBox(height: 10),
                       Obx(
                    () => authRepo.isFacebookLinked.value
                        ? const SizedBox.shrink()
                        : LinkAccountButton(
                            buttonText: 'linkFacebookAccount'.tr,
                            imagePath: kFacebookImage,
                            onPressed: () => authRepo.linkWithFacebook(),
                            backgroundColor: Colors.blueAccent,
                            textColor: Colors.white,
                            enabled: true,
                          ),
                  ),*/
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Obx(
                        () => LinkAccountButton(
                          buttonText: controller.authRep.isGoogleLinked.value
                              ? 'changeGoogleAccount'.tr
                              : 'linkGoogleAccount'.tr,
                          imagePath: kGoogleImage,
                          onPressed: () => controller.authRep.linkWithGoogle(),
                        ),
                      ),
                      /*  const SizedBox(width: 10),
                      Obx(
                    () => authRepo.isFacebookLinked.value
                        ? const SizedBox.shrink()
                        : LinkAccountButton(
                            buttonText: 'linkFacebookAccount'.tr,
                            imagePath: kFacebookImage,
                            onPressed: () => authRepo.linkWithFacebook(),
                            backgroundColor: Colors.blueAccent,
                            textColor: Colors.white,
                            enabled: true,
                          ),
                  ),*/
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
