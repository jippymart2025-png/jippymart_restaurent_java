import 'package:flutter/material.dart';

/// Centralized input decoration helpers for the app.
class AppInputDecoration {
  AppInputDecoration._();

  /// Standard box-style decoration used across forms.
  static InputDecoration box({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      floatingLabelStyle: const TextStyle(color: Colors.red, fontSize: 14),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(color: Colors.red, width: 1.5),
    );
  }

  static OutlineInputBorder _border({
    Color color = const Color(0xFFE0E0E0),
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}