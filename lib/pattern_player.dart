import 'dart:async';
import 'dart:math';

import 'package:beatrain/note.dart';
import 'package:beatrain/pattern.dart';
import 'package:flutter/material.dart';

enum Judgement { miss, good, perfect }

class PatternPlayer extends ChangeNotifier {
  static const maxFps = 200;
  static const perfectJudgementMs = 25;
  static const missJudgementMs = 50;
  final Pattern pattern;
  final int keyLength;
  final _judgementStreamController = StreamController<Judgement>.broadcast();
  Stream<Judgement> get judgementStream => _judgementStreamController.stream;

  int _currentMs = 0;
  int get currentMs => _currentMs;
  int _combo = 0;
  int get combo => _combo;

  Timer? _frameGenerator;

  int _nextLoadMs = 3000;
  int _loadIntervalMs = 3000;

  double _speed = 2.0;
  double get speed => _speed;

  int _hitNoteCount = 0;
  double _accuracySum = 0;
  double _accuracy = 0;
  double get accuracy => _accuracy;

  PatternPlayer(this.pattern) : keyLength = pattern.keyLength {
    _init();
  }

  void _init() {
    _combo = 0;
    _currentMs = 0;
    _nextLoadMs = 3000;
    _loadIntervalMs = 3000;
    _hitNoteCount = 0;
    _accuracySum = 0;
    _accuracy = 0;
    pattern.loadNotes(0, _nextLoadMs + _loadIntervalMs);
  }

  void play() {
    int lastTimestamp = DateTime.now().millisecondsSinceEpoch;
    _frameGenerator?.cancel();
    _frameGenerator =
        Timer.periodic(const Duration(milliseconds: 1000 ~/ maxFps), (timer) {
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
    notifyListeners();
  }

  void _checkMiss() {
    for (List<Note> queue in pattern.noteQueues) {
      if (queue.isEmpty) continue;

      if (_currentMs - queue.first.ms > missJudgementMs) {
        _onMiss();
        queue.removeAt(0);
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

  void replay() {
    pattern.noteQueues.forEach((queue) {
      queue.clear();
    });
    _init();
    play();
  }

  void enterKey(int key) {
    final queue = pattern.noteQueues[key];

    if (queue.isEmpty) return;

    final diffMs = (queue.first.ms - _currentMs).abs() ~/ 2;

    if (diffMs <= missJudgementMs) {
      if (diffMs <= perfectJudgementMs) {
        _onPerfect();
      } else {
        _onGood(diffMs);
      }
      
      _hitNoteCount++;
      _accuracy = _accuracySum / _hitNoteCount;
      queue.removeAt(0);
    }
  }

  void _onMiss() {
    _combo = 0;
    _judgementStreamController.sink.add(Judgement.miss);
  }

  void _onGood(int diffMs) {
    _combo++;
    _accuracySum += (1 -
        (diffMs - perfectJudgementMs) / (missJudgementMs - perfectJudgementMs));

    _judgementStreamController.sink.add(Judgement.good);
  }

  void _onPerfect() {
    _combo++;
    _accuracySum += 1;

    _judgementStreamController.sink.add(Judgement.perfect);
  }

  void dispose() {
    _frameGenerator?.cancel();
    _judgementStreamController.close();
    super.dispose();
  }

  void speedUp() {
    _speed = min(5.0, _speed + 0.25);
  }

  void speedDown() {
    _speed = max(0.25, _speed - 0.25);
  }
}
