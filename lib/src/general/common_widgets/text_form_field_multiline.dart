import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormFieldMultiline extends StatelessWidget {
  const TextFormFieldMultiline({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.textController,
    required this.textInputAction,
    this.inputFormatter,
    this.onSubmitted,
    this.validationFunction,
  });
  final String labelText;
  final String hintText;
  final TextEditingController textController;
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
        maxLines: null,
        onFieldSubmitted:
            onSubmitted != null ? (enteredString) => onSubmitted!() : null,
        inputFormatters: inputFormatter != null ? [inputFormatter!] : [],
        controller: textController,
        keyboardType: TextInputType.multiline,
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
          prefixIcon: const Icon(
            Icons.lock_outlined,
          ),
          labelText: labelText,
          hintText: hintText,
        ),
        validator: validationFunction,
      ),
    );
  }
}
