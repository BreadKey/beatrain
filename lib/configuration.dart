import 'package:flutter/services.dart';

class Configuration {
  static final _instance = Configuration._();
  Configuration._();

  factory Configuration() => _instance;

  final keySettings = {
    4: [
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.semicolon,
      LogicalKeyboardKey.quote
    ],
    6: [
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.keyS,
      LogicalKeyboardKey.keyD,
      LogicalKeyboardKey.keyL,
      LogicalKeyboardKey.semicolon,
      LogicalKeyboardKey.quote
    ],
  };
}
