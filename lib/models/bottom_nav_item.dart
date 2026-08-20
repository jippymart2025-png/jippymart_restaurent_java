import 'package:flutter/foundation.dart';

enum BottomNavId {
  home,
  dineIn,
  inventory,
  subscription,
  sales,
  profile,
}

@immutable
class BottomNavItem {
  const BottomNavItem({
    required this.id,
    required this.icon,
    required this.label,
  });

  final BottomNavId id;
  final String icon;
  final String label;
}