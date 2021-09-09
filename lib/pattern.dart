import 'package:beatrain/note.dart';

abstract class Pattern {
  final String name;
  final int bpm;
  final int keyLength;
  final int level;
  final int durationMs;
  final List<List<Note>> noteQueues;

  Pattern(this.name, this.bpm, this.keyLength, this.level, this.durationMs)
      : noteQueues = List.generate(keyLength, (index) => []);

  void loadNotes(int fromMs, int toMs);
}
