import 'package:flutter/material.dart';

class TextFieldDecoration {
  static InputDecoration filled({required String hint, Widget? suffix}) {
    return InputDecoration(
      fillColor: Colors.grey.shade100,
      filled: true,
      hintStyle: const TextStyle(fontSize: 14),
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 12,
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      suffixIcon: suffix,
    );
  }
}
