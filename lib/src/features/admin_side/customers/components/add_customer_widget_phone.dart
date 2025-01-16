import 'package:cortadoeg/src/features/admin_side/customers/controllers/customers_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart' as intl;

import '../../../../general/general_functions.dart';
import '../../../../general/validation_functions.dart';

class AdminAddCustomerWidgetPhone extends StatelessWidget {
  const AdminAddCustomerWidgetPhone({
    super.key,
    required this.controller,
    required this.edit,
    this.initialNumber,
    required this.onPress,
  });
  final AdminCustomersScreenController controller;
  final bool edit;
  final String? initialNumber;
  final Function onPress;
  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final isEnglish = isLangEnglish();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'customerInformation'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    inputFormatters: [LengthLimitingTextInputFormatter(100)],
                    controller: controller.nameTextController,
                    keyboardType: TextInputType.text,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      prefixIcon: const Icon(Icons.person),
                      labelText: 'fullName'.tr,
                      hintText: 'enterFullName'.tr,
                    ),
                    validator: textNotEmpty,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: intl.IntlPhoneField(
                    initialValue: edit ? initialNumber : null,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelStyle: const TextStyle(color: Colors.black),
                      labelText: 'phoneLabel'.tr,
                      hintText: 'phoneFieldLabel'.tr,
                    ),
                    initialCountryCode: 'EG',
                    invalidNumberMessage: 'invalidNumberMsg'.tr,
                    countries: const [
                      Country(
                        name: "Egypt",
                        nameTranslations: {
                          "en": "Egypt",
                          "ar": "مصر",
                        },
                        flag: "🇪🇬",
                        code: "EG",
                        dialCode: "20",
                        minLength: 10,
                        maxLength: 10,
                      ),
                    ],
                    pickerDialogStyle: PickerDialogStyle(
                      searchFieldInputDecoration:
                          InputDecoration(hintText: 'searchCountry'.tr),
                    ),
                    onChanged: (phone) {
                      controller.number.value = phone.completeNumber;
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Row(
              children: [
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.percentageChosen.value = false;
                    },
                    style: ElevatedButton.styleFrom(
                      overlayColor: Colors.grey,
                      backgroundColor: controller.percentageChosen.value
                          ? Colors.grey.shade200
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Icon(
                      Icons.attach_money_rounded,
                      color: controller.percentageChosen.value
                          ? Colors.black54
                          : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.percentageChosen.value = true;
                    },
                    style: ElevatedButton.styleFrom(
                      overlayColor: Colors.grey,
                      backgroundColor: controller.percentageChosen.value
                          ? Colors.black
                          : Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Icon(
                      Icons.percent_rounded,
                      color: controller.percentageChosen.value
                          ? Colors.white
                          : Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    controller: controller.discountTextController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintText: '0',
                      isDense: true,
                    ),
                    cursorColor: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            width: double.maxFinite,
            child: ElevatedButton(
              onPressed: () => onPress(),
              style: ElevatedButton.styleFrom(
                overlayColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.black,
              ),
              child: Text(
                edit ? 'edit'.tr : 'add'.tr,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
