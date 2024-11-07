import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/enums.dart';

class TextFormFieldRegular extends StatelessWidget {
  const TextFormFieldRegular({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.prefixIconData,
    required this.textController,
    required this.inputType,
    required this.editable,
    required this.textInputAction,
    this.inputFormatter,
    this.onSubmitted,
    this.validationFunction,
  });
  final String labelText;
  final String hintText;
  final IconData prefixIconData;
  final TextEditingController textController;
  final InputType inputType;
  final bool editable;
  final TextInputAction textInputAction;
  final TextInputFormatter? inputFormatter;
  final Function? onSubmitted;
  final String? Function(String?)? validationFunction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextFormField(
        textInputAction: textInputAction,
        onFieldSubmitted:
            onSubmitted != null ? (enteredString) => onSubmitted!() : null,
        inputFormatters: inputFormatter != null ? [inputFormatter!] : [],
        enabled: editable,
        controller: textController,
        keyboardType: inputType == InputType.email
            ? TextInputType.emailAddress
            : inputType == InputType.numbers
                ? TextInputType.number
                : TextInputType.text,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25)),
            borderSide:
                BorderSide(color: Colors.black), // Border color when focused
          ),
          prefixIcon: Icon(
            prefixIconData,
          ),
          labelText: labelText,
          hintText: hintText,
        ),
        validator: validationFunction,
      ),
    );
  }
}
