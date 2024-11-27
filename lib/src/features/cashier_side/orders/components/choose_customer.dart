import 'package:anim_search_app_bar/anim_search_app_bar.dart';
import 'package:cortadoeg/src/features/cashier_side/orders/components/models.dart';
import 'package:cortadoeg/src/general/general_functions.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../constants/enums.dart';
import '../../../../general/validation_functions.dart';
import '../controllers/customer_choose_controller.dart';

class ChooseCustomer extends StatelessWidget {
  const ChooseCustomer({
    super.key,
    required this.customers,
  });
  final List<CustomerModel> customers;

  @override
  Widget build(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    final screenWidth = getScreenWidth(context);
    final controller = Get.put(CustomerChooseController(customers: customers));
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        Get.delete<CustomerChooseController>();
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Center(
          child: Container(
            height: screenHeight * 0.7,
            width: screenWidth * 0.5,
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                const SizedBox(height: 10),
                AnimSearchAppBar(
                  keyboardType: TextInputType.text,
                  cancelButtonTextStyle: const TextStyle(color: Colors.black87),
                  cancelButtonText: 'cancel'.tr,
                  hintText: 'searchItemsHint'.tr,
                  onChanged: (searchText) {
                    controller.filteredCustomers.value = searchText
                            .trim()
                            .isEmpty
                        ? customers
                        : customers
                            .where((customer) => customer.name
                                .toUpperCase()
                                .contains(searchText.toUpperCase().trimLeft()))
                            .toList();
                  },
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    leading: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 25,
                        color: Colors.black,
                      ),
                    ),
                    elevation: 0,
                    title: Text(
                      'chooseCustomer'.tr,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                    centerTitle: true,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.white,
                    surfaceTintColor: Colors.white,
                  ),
                ),
                Expanded(
                  child: StretchingOverscrollIndicator(
                    axisDirection: AxisDirection.down,
                    child: Obx(
                      () => ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: controller.filteredCustomers.length + 1,
                        itemBuilder: (context, index) {
                          return index == 0
                              ? addCustomerTile(controller: controller)
                              : customerTile(
                                  controller.filteredCustomers[index - 1]);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget addCustomerTile({required CustomerChooseController controller}) {
    return ExpansionTileCard(
      onExpansionChanged: (extendStatus) {
        controller.extended.value = extendStatus;
      },
      backgroundColor: Colors.white,
      collapsedBackgroundColor: Colors.white,
      expansionKey: controller.key0,
      elevation: 0,
      tilePadding: const EdgeInsets.all(0),
      isHasTrailing: false,
      childrenPadding: EdgeInsets.zero,
      initiallyExpanded: false,
      isHideSubtitleOnExpanded: true,
      title: Padding(
        padding: const EdgeInsets.all(10),
        child: Obx(
          () => Row(
            children: [
              Icon(
                controller.extended.value ? Icons.remove : Icons.add_rounded,
                size: 25,
                color: Colors.black54,
              ),
              const SizedBox(width: 10),
              Text(
                controller.extended.value ? 'cancel'.tr : 'addCustomer'.tr,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w800,
                ),
              )
            ],
          ),
        ),
      ),
      children: [_buildChildren(controller: controller)],
    );
  }

  Widget _buildChildren({required CustomerChooseController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'customerInformation'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Form(
            key: controller.formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
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
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 10, right: 10),
                    child: IntlPhoneField(
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
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final discountText =
                            controller.discountTextController.text.trim();
                        final name = controller.nameTextController.text.trim();
                        if (controller.formKey.currentState!.validate() &&
                            isNumeric(discountText)) {
                          final customerModel = CustomerModel(
                            customerId: '',
                            name: name,
                            number: controller.number.value,
                            discountType: controller.percentageChosen.value
                                ? 'percentage'
                                : 'value',
                            discountValue: double.parse(discountText),
                          );
                          Get.back(result: customerModel);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        overlayColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.black,
                      ),
                      child: Text(
                        'add'.tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget customerTile(CustomerModel customerModel) {
    return Material(
      color: Colors.white,
      child: InkWell(
        splashFactory: InkSparkle.splashFactory,
        onTap: () => Get.back(result: customerModel),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.lightGreen,
                child: Text(
                  customerModel.name[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                customerModel.name,
                style: const TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.w800,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool isNumeric(String str) {
    if (str.isEmpty) {
      showSnackBar(
          text: 'enterDiscountValue'.tr, snackBarType: SnackBarType.error);
      return false;
    } else if (double.tryParse(str) == null) {
      showSnackBar(text: 'enterNumber'.tr, snackBarType: SnackBarType.error);
      return false;
    } else {
      return true;
    }
  }
}
