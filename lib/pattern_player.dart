import 'dart:async';
import 'dart:collection';

import 'package:beatrain/note.dart';
import 'package:beatrain/pattern.dart';

class PatternPlayer {
  static const perfectJudgementMs = 25;
  static const missJudgementMs = 50;
  final Pattern pattern;

  int _currentMs = 0;
  int _combo = 0;
  int get combo => _combo;

  Timer? _frameGenerator;

  int _nextLoadMs = 3000;
  int _loadIntervalMs = 3000;

  PatternPlayer(this.pattern) {
    pattern.loadNotes(0, _nextLoadMs + _loadIntervalMs);
  }

  void play() {
    int lastTimestamp = DateTime.now().millisecondsSinceEpoch;
    _frameGenerator = Timer.periodic(const Duration(milliseconds: 1), (timer) {
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;

      _update(currentTimestamp - lastTimestamp);
      lastTimestamp = currentTimestamp;
    });
  }

  void _update(int ms) {
    _currentMs += ms;
    _checkMiss();

    if (_currentMs >= pattern.durationMs) {
      pause();
    } else {
      _loadNotes();
    }
  }

  void _checkMiss() {
    for (Queue<Note> queue in pattern.noteQueues) {
      if (queue.isEmpty) continue;

      if (_currentMs - queue.first.ms > missJudgementMs) {
        _onMiss();
        queue.removeFirst();
      }
    }
  }

  void _loadNotes() {
    if (_currentMs >= _nextLoadMs) {
      _nextLoadMs += _loadIntervalMs;
      pattern.loadNotes(_nextLoadMs, _nextLoadMs + _loadIntervalMs);
    }
  }

  void pause() {
    _frameGenerator?.cancel();
  }

  void enterKey(int key) {
    final queue = pattern.noteQueues[key];

    if (queue.isEmpty) return;

    final diffMs = (queue.first.ms - _currentMs).abs();

    if (diffMs <= missJudgementMs) {
      if (diffMs <= perfectJudgementMs) {
        _onPerfect();
      } else {
        _onGood();
      }
      queue.removeFirst();
    }
  }

  void _onMiss() {
    print("miss");
    _combo = 0;
  }

  void _onGood() {
    _combo++;
  }

  void _onPerfect() {
    _combo++;
  }

  void dispose() {
    _frameGenerator?.cancel();
  }
}
