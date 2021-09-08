class Note {
  final int index;
  final int ms;
  const Note(this.index, this.ms);
}

class HitNote {
  final int index;
  final int diffMs;
  int animationMs = 0;

  HitNote(this.index, this.diffMs);
}
