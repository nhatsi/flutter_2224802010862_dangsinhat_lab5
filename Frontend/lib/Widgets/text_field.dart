import 'package:flutter/material.dart';
import 'colors.dart';

class TextFeild extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController controller;
  final Icon icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool errorText;

  const TextFeild({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
    required this.icon,
    required this.obscureText,
    required this.keyboardType,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      style: const TextStyle(
        color: black,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: inputFillColor,
        labelText: labelText,
        hintText: hintText,
        errorText: errorText ? 'Vui lòng không để trống' : null,
        labelStyle: const TextStyle(
          color: grey,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(
          color: grey,
          fontSize: 14,
        ),
        suffixIcon: Icon(
          icon.icon,
          color: primaryColor,
          size: 22,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: red,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}