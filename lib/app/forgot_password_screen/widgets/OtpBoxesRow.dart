import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../themes/app_them_data.dart';
import '../controller/forgot_password_controller.dart';

class OtpBoxesRow extends StatefulWidget {
  final ForgotPasswordController controller;
  final bool isDark;

  const OtpBoxesRow({required this.controller, required this.isDark});

  @override
  State<OtpBoxesRow> createState() => _OtpBoxesRowState();
}

class _OtpBoxesRowState extends State<OtpBoxesRow> {
  static const int otpLength = 6;
  late final List<TextEditingController> _digitControllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _digitControllers =
        List.generate(otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(otpLength, (_) => FocusNode());

    // If the OTP field already has a value (e.g. restored state), split it
    // across the boxes.
    final existing = widget.controller.otpEditingController.value.text;
    for (var i = 0; i < existing.length && i < otpLength; i++) {
      _digitControllers[i].text = existing[i];
    }
  }

  @override
  void dispose() {
    for (final c in _digitControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _syncToOtpController() {
    final otp = _digitControllers.map((c) => c.text).join();
    widget.controller.otpEditingController.value.text = otp;
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    _syncToOtpController();
  }

  @override
  Widget build(BuildContext context) {
    final boxColor =
    widget.isDark ? AppThemeData.grey800 : const Color(0xFFF5F0EB);
    final textColor =
    widget.isDark ? AppThemeData.grey50 : AppThemeData.grey900;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(otpLength, (index) {
        return SizedBox(
          width: 46,
          height: 52,
          child: TextField(
            controller: _digitControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 20,
              fontFamily: AppThemeData.semiBold,
              color: textColor,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: boxColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppThemeData.primary300,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (value) => _onChanged(value, index),
          ),
        );
      }),
    );
  }
}