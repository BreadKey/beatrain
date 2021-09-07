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
  static const minSpeed = 0.25;
  static const maxSpeed = 5.0;

  final Pattern pattern;
  final int keyLength;
  final int bpm;
  final _judgementStreamController = StreamController<Judgement>.broadcast();
  Stream<Judgement> get judgementStream => _judgementStreamController.stream;

  final _hitNoteStreamController = StreamController<Note>.broadcast();
  Stream<Note> get hitNoteStream => _hitNoteStreamController.stream;

  int _currentMs = 0;
  int get currentMs => _currentMs;
  int _combo = 0;
  int get combo => _combo;

  Timer? _frameGenerator;

  double _speed = 1.0;
  double get speed => _speed;

  int _hitNoteCount = 0;
  double _accuracySum = 0;
  double _accuracy = 0;
  double get accuracy => _accuracy;

  late _LoadInfo _loadInfo;

  PatternPlayer(this.pattern)
      : keyLength = pattern.keyLength,
        bpm = pattern.bpm {
    _init();
  }

  void _init() {
    _combo = 0;
    _currentMs = 0;
    _loadInfo = _getNextLoadInfo();
    _hitNoteCount = 0;
    _accuracySum = 0;
    _accuracy = 0;
    pattern.loadNotes(_loadInfo.from, _loadInfo.to);
  }

  _LoadInfo _getNextLoadInfo({_LoadInfo? before}) {
    final from = before?.to ?? 0;
    final to = from + (60000 / pattern.bpm * 8).round();
    final next = (to - (to - from) / speed).round();

    return _LoadInfo(from, to, next);
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
    if (_currentMs >= _loadInfo.next) {
      print("new");
      _loadInfo = _getNextLoadInfo(before: _loadInfo);
      pattern.loadNotes(_loadInfo.from, _loadInfo.to);
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
      _hitNoteStreamController.sink.add(queue.removeAt(0));
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
    _hitNoteStreamController.close();
    super.dispose();
  }

  void speedUp() {
    _speed = min(maxSpeed, _speed + 0.25);
  }

  void speedDown() {
    _speed = max(minSpeed, _speed - 0.25);
  }
}

class _LoadInfo {
  final int from;
  final int to;
  final int next;

  const _LoadInfo(this.from, this.to, this.next);
}
