import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormFieldMultiline extends StatelessWidget {
  const TextFormFieldMultiline({
    super.key,
    this.labelText,
    required this.hintText,
    required this.textController,
    required this.textInputAction,
    this.inputFormatter,
    this.onSubmitted,
    this.validationFunction,
  });
  final String? labelText;
  final String hintText;
  final TextEditingController textController;
  final TextInputAction textInputAction;
  final TextInputFormatter? inputFormatter;
  final Function? onSubmitted;
  final String? Function(String?)? validationFunction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        textInputAction: textInputAction,
        maxLines: 5,
        onFieldSubmitted:
            onSubmitted != null ? (enteredString) => onSubmitted!() : null,
        inputFormatters: inputFormatter != null ? [inputFormatter!] : [],
        controller: textController,
        keyboardType: TextInputType.multiline,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          labelStyle: const TextStyle(color: Colors.black87),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[200],
          labelText: labelText,
          hintText: hintText,
        ),
        validator: validationFunction,
      ),
    );
  }
}
