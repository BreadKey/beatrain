import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:beatrain/pattern.dart';

class SpeedManager {
  static const maxSpeed = 5.0;
  static const minSpeed = 0.25;
  static final instance = SpeedManager._();
  SpeedManager._();

  final _cache = <Pattern, double>{};

  final _prefs = SharedPreferences.getInstance();

  Future<double> currentSpeedOf(Pattern pattern) async {
    if (_cache[pattern] == null) {
      _cache[pattern] = (await _prefs).getDouble(_generateKey(pattern)) ?? 1.0;
    }

    return _cache[pattern]!;
  }

  double cachedSpeedOf(Pattern pattern) => _cache[pattern] ?? 1.0;

  Future speedUp(Pattern pattern) async {
    if (_cache[pattern] == null) return;

    _cache[pattern] = min(maxSpeed, _cache[pattern]! + 0.25);

    return (await _prefs).setDouble(_generateKey(pattern), _cache[pattern]!);
  }

  Future speedDown(Pattern pattern) async {
    if (_cache[pattern] == null) return;

    _cache[pattern] = max(minSpeed, _cache[pattern]! - 0.25);

    return (await _prefs).setDouble(_generateKey(pattern), _cache[pattern]!);
  }

  String _generateKey(Pattern pattern) =>
      pattern.name + "${pattern.keyLength}" + "${pattern.level}";
}
