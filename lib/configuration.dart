import 'package:flutter/services.dart';

class Configuration {
  static final instance = Configuration._();
  Configuration._();

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
