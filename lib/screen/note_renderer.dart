import 'package:beatrain/screen/play_screen.dart';
import 'package:flutter/material.dart';

abstract class NoteRenderer {
  const NoteRenderer();

  void render(
      int keyLength, int keyIndex, Canvas canvas, Offset center, Size size);
}

class DefaultNoteRenderer extends NoteRenderer {
  const DefaultNoteRenderer();

  static const kKeyColors = {
    4: {0: Colors.white, 1: Colors.blue, 2: Colors.white, 3: Colors.blue},
    6: {
      0: Colors.white,
      1: Colors.blue,
      2: Colors.white,
      3: Colors.white,
      4: Colors.blue,
      5: Colors.white,
    }
  };

  @override
  void render(
      int keyLength, int keyIndex, Canvas canvas, Offset center, Size size) {
    const radius = PlayScreen.kJudgementLineThickness / 2 * 0.618;

    final paint = Paint()..color = kKeyColors[keyLength]![keyIndex]!;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: center, width: size.width, height: PlayScreen.kJudgementLineThickness),
            Radius.circular(radius / 2)),
        paint);

    canvas.drawCircle(center, radius, paint..color = Colors.red);
  }
}
