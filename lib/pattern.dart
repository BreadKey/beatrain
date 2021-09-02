import 'dart:collection';

import 'package:beatrain/note.dart';

abstract class Pattern {
  final String name;
  final int keyLength;
  final int durationMs;
  final List<Queue<Note>> noteQueues;

  Pattern(this.name, this.keyLength, this.durationMs)
      : noteQueues = List.generate(keyLength, (index) => Queue());

  void loadNotes(int fromMs, int toMs);
}
