// lib/data/datasource/local/club_schedule_local_datasource.dart

import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/club/club_schedule_defaults.dart';

class ClubScheduleLocalDatasource {
  static const String _courtCountPrefix = 'club_schedule_court_count_';
  static const String _courtCostPrefix = 'club_schedule_court_cost_';

  static final Map<String, ClubScheduleDefaults> _cache = {};

  static Future<ClubScheduleDefaults> getDefaults(String clubId) async {
    if (clubId.isEmpty) return const ClubScheduleDefaults();
    if (_cache.containsKey(clubId)) {
      return _cache[clubId]!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt('$_courtCountPrefix$clubId') ?? 1;
      final cost = prefs.getDouble('$_courtCostPrefix$clubId') ?? 0.0;
      final defaults = ClubScheduleDefaults(
        courtCount: count > 0 ? count : 1,
        courtRentalCost: cost,
      );
      _cache[clubId] = defaults;
      return defaults;
    } catch (_) {
      return const ClubScheduleDefaults();
    }
  }

  static ClubScheduleDefaults getDefaultsSync(String clubId) {
    if (clubId.isEmpty) return const ClubScheduleDefaults();
    return _cache[clubId] ?? const ClubScheduleDefaults();
  }

  static Future<void> saveDefaults(
    String clubId, {
    required int courtCount,
    required double courtRentalCost,
  }) async {
    if (clubId.isEmpty) return;
    final validCount = courtCount > 0 ? courtCount : 1;
    final defaults = ClubScheduleDefaults(
      courtCount: validCount,
      courtRentalCost: courtRentalCost,
    );
    _cache[clubId] = defaults;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_courtCountPrefix$clubId', validCount);
      await prefs.setDouble('$_courtCostPrefix$clubId', courtRentalCost);
    } catch (_) {}
  }
}
