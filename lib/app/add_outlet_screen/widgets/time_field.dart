import 'package:flutter/material.dart';

/// Read-only time field that opens a time picker on tap.
class TimeField extends StatelessWidget {
  const TimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.icon = Icons.access_time,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.trim().isEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.red.shade300),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        child: Text(
          isEmpty ? "Select time" : value,
          style: TextStyle(
            color: isEmpty ? Colors.grey : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}