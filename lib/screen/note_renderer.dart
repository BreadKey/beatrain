import 'package:beatrain/note.dart';
import 'package:beatrain/pattern_player.dart';
import 'package:beatrain/screen/play_screen.dart';
import 'package:flutter/material.dart';

abstract class NoteRenderer {
  const NoteRenderer();

  void renderNote(
      int keyLength, Note note, Canvas canvas, Offset center, Size size);
  void renderHitNote(
      int keyLength, HitNote hitNote, Canvas canvas, Offset center, Size size);
}

class DefaultNoteRenderer extends NoteRenderer {
  static const pointerRadius = PlayScreen.kJudgementLineThickness / 2 * 0.618;
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
  void renderNote(
      int keyLength, Note note, Canvas canvas, Offset center, Size size) {
    final paint = Paint()..color = kKeyColors[keyLength]![note.index]!;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: center,
                width: size.width,
                height: PlayScreen.kJudgementLineThickness),
            Radius.circular(pointerRadius / 2)),
        paint);

    canvas.drawCircle(center, pointerRadius, paint..color = Colors.red);
  }

  @override
  void renderHitNote(
      int keyLength, HitNote hitNote, Canvas canvas, Offset center, Size size) {
    final animationRatio =
        hitNote.animationMs / PatternPlayer.hitEffectAnimationMs;

    final paint = Paint()..color = Colors.red.withOpacity(1 - animationRatio);
    canvas.drawCircle(center, pointerRadius * (1 + animationRatio), paint);
  }
}
