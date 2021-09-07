import 'package:beatrain/screen/play_screen/judgement_board.dart';
import 'package:beatrain/note.dart';
import 'package:beatrain/screen/note_renderer.dart';
import 'package:beatrain/pattern_player.dart';
import 'package:beatrain/screen/play_screen.dart';
import 'package:flutter/material.dart';

class NoteScreen extends StatelessWidget {
  final PatternPlayer patternPlayer;
  final NoteRenderer noteRenderer;

  const NoteScreen(
      {Key? key, required this.patternPlayer, NoteRenderer? noteRenderer})
      : this.noteRenderer = noteRenderer ?? const DefaultNoteRenderer(),
        super(key: key);

  @override
  Widget build(BuildContext context) => Stack(children: [
        Column(
          children: [
            Expanded(child: JudgementBoard(patternPlayer: patternPlayer)),
            const Divider(
              color: Colors.transparent,
            ),
            Container(
              height: PlayScreen.kJudgementLineHeight,
              alignment: Alignment.topCenter,
              child: Container(
                height: PlayScreen.kJudgementLineThickness,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Colors.lightBlueAccent.withOpacity(0.5),
                  Colors.lightBlueAccent.shade100.withOpacity(0.5),
                  Colors.lightBlueAccent.withOpacity(0.5)
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(patternPlayer.keyLength, (keyIndex) {
            return Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: CustomPaint(
                painter:
                    _NoteQueuePainter(patternPlayer, keyIndex, noteRenderer),
              ),
            ));
          }),
        )
      ]);
}

class _NoteQueuePainter extends CustomPainter {
  final NoteRenderer noteRenderer;
  final PatternPlayer patternPlayer;
  final int keyIndex;
  final double msPerBeat;

  _NoteQueuePainter(this.patternPlayer, this.keyIndex, this.noteRenderer)
      : msPerBeat = 60000 / patternPlayer.bpm,
        super(repaint: patternPlayer);

  @override
  void paint(Canvas canvas, Size size) {
    const judgementLineCenterY = PlayScreen.kJudgementLineHeight -
        PlayScreen.kJudgementLineThickness / 2;
    final noteQueue = patternPlayer.pattern.noteQueues[keyIndex];

    for (Note note in noteQueue) {
      final center = Offset(
          size.width / 2,
          size.height -
              (((note.ms - patternPlayer.currentMs) / msPerBeat) *
                  (PlayScreen.kPixelPerBeat) *
                  patternPlayer.speed) -
              judgementLineCenterY);

      noteRenderer.render(
          patternPlayer.keyLength, keyIndex, canvas, center, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
