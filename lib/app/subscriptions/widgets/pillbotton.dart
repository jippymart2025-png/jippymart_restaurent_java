import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jippymart_restaurant/app/subscriptions/widgets/tok.dart';

import '../../../themes/app_them_data.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    required this.label,
    required this.gradient,
    required this.onPressed,
    this.fullWidth = false,
    this.compact = false,
  });
  final String label;
  final Gradient gradient;
  final VoidCallback onPressed;
  final bool fullWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final inner = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(Tok.r99),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: fullWidth ? 0 : Tok.s20,
            vertical: fullWidth
                ? (compact ? Tok.s10 : Tok.s16)
                : Tok.s10,
          ),
          alignment: fullWidth ? Alignment.center : null,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(Tok.r99),
            boxShadow: [
              BoxShadow(
                color: _gradFirstColor(gradient).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppThemeData.semiBold,
              fontSize: fullWidth ? (compact ? Tok.f13 : Tok.f16) : Tok.f13,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
    if (fullWidth) {
      return SizedBox(width: double.infinity, child: inner);
    }
    return inner;
  }

  Color _gradFirstColor(Gradient g) {
    if (g is LinearGradient && g.colors.isNotEmpty) return g.colors.first;
    return AppThemeData.secondary300;
  }
}
