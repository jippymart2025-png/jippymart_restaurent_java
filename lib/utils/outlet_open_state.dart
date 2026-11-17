/// Derives an outlet's live open/closed state from the outlet API payload.
///
/// The outlet API does not return `isOpen`; it must be computed from
/// `isActive` plus today's entry in `operatingDays`.
class OutletOpenState {
  const OutletOpenState._();

  /// Returns `true` only when the outlet is active, today's schedule is open,
  /// and [now] falls inside today's opening window.
  ///
  /// Overnight windows (`closingTime < openingTime`) wrap past midnight.
  /// `dayOfWeekId` uses the same 1=Mon..7=Sun convention as [DateTime.weekday].
  static bool isCurrentlyOpen(
    Map<String, dynamic> outlet, {
    DateTime? now,
  }) {
    if (_asBool(outlet['isActive']) != true) return false;

    final localNow = now ?? DateTime.now();
    final rawDays = outlet['operatingDays'];
    if (rawDays is! List) return false;

    Map<String, dynamic>? today;
    for (final rawDay in rawDays) {
      if (rawDay is! Map) continue;
      final day = Map<String, dynamic>.from(rawDay);
      if (_asInt(day['dayOfWeekId']) == localNow.weekday) {
        today = day;
        break;
      }
    }

    if (today == null) return false;
    if (_asBool(today['isOpen']) != true) return false;

    final opening = _parseClock(today['openingTime']);
    final closing = _parseClock(today['closingTime']);
    if (opening == null || closing == null) return false;

    final currentSeconds =
        localNow.hour * 3600 + localNow.minute * 60 + localNow.second;

    // Overnight window: open until closing time tomorrow.
    if (closing < opening) {
      return currentSeconds >= opening || currentSeconds < closing;
    }

    return currentSeconds >= opening && currentSeconds < closing;
  }

  /// Parses `HH:mm`, `HH:mm:ss`, or an ISO time suffix into seconds of day.
  static int? _parseClock(dynamic raw) {
    if (raw == null) return null;

    final text = raw.toString().trim();
    if (text.isEmpty) return null;

    final timePart = text.contains('T') ? text.split('T').last : text;
    final parts = timePart.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    // Ignore fractional seconds such as "07:30:00.000".
    final secondText = parts.length > 2 ? parts[2].split('.').first : null;
    final second = int.tryParse(secondText ?? '') ?? 0;
    if (second < 0 || second > 59) return null;

    return hour * 3600 + minute * 60 + second;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      switch (value.trim().toUpperCase()) {
        case 'TRUE':
        case '1':
        case 'Y':
        case 'YES':
          return true;
        case 'FALSE':
        case '0':
        case 'N':
        case 'NO':
          return false;
      }
    }
    return null;
  }
}
