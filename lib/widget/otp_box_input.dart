import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A 6-box segmented OTP input. Auto-advances focus as digits are typed,
/// and moves back on backspace. Reports the combined code via [onChanged].
class OtpBoxInput extends StatefulWidget {
  const OtpBoxInput({
    super.key,
    required this.onChanged,
    this.length = 6,
  });

  final void Function(String code) onChanged;
  final int length;

  @override
  State<OtpBoxInput> createState() => _OtpBoxInputState();
}

class _OtpBoxInputState extends State<OtpBoxInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _handleChange(int index, String value) {
    if (value.length == 1 && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    widget.onChanged(_controllers.map((c) => c.text).join());
  }

  /// Call this to clear all boxes (e.g. after a failed attempt or resend).
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 46,
          height: 56,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: const Color(0xFFF5F3F2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFC3BFBC), width: 2),
              ),
            ),
            onChanged: (value) => _handleChange(index, value),
          ),
        );
      }),
    );
  }
}