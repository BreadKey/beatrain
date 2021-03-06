import 'dart:async';

import 'package:beatrain/note.dart';
import 'package:beatrain/pattern.dart';
import 'package:beatrain/speed_manager.dart';
import 'package:flutter/material.dart';

enum Judgement { miss, good, perfect }

class PatternPlayer extends ChangeNotifier {
  static const maxFps = 200;
  static const perfectJudgementMs = 25;
  static const missJudgementMs = 50;
  static const hitEffectAnimationMs = 100;

  final Pattern pattern;
  final int keyLength;
  final int bpm;
  final _judgementStreamController = StreamController<Judgement>.broadcast();
  Stream<Judgement> get judgementStream => _judgementStreamController.stream;

  int _currentMs = 0;
  int get currentMs => _currentMs;
  int _combo = 0;
  int get combo => _combo;

  Timer? _frameGenerator;

  int _hitNoteCount = 0;
  double _accuracySum = 0;
  double _accuracy = 0;
  double get accuracy => _accuracy;

  late _LoadInfo _loadInfo;

  final List<List<HitNote>> _hitNotesByKey;
  Iterable<HitNote> hitNotesAt(int keyIndex) => _hitNotesByKey[keyIndex];

  PatternPlayer(this.pattern)
      : keyLength = pattern.keyLength,
        _hitNotesByKey = List.generate(pattern.keyLength, (index) => []),
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

    for (List<HitNote> hitNotes in _hitNotesByKey) {
      hitNotes.clear();
    }

    pattern.noteQueues.forEach((queue) {
      queue.clear();
    });

    pattern.loadNotes(_loadInfo.from, _loadInfo.to);
  }

  _LoadInfo _getNextLoadInfo({_LoadInfo? before}) {
    final from = before?.to ?? 0;
    final to = from + (60000 / pattern.bpm * 8).round();
    final next =
        (to - (to - from) / SpeedManager.instance.cachedSpeedOf(pattern))
            .round();

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
    _updateHitNotes(ms);
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
      _loadInfo = _getNextLoadInfo(before: _loadInfo);
      pattern.loadNotes(_loadInfo.from, _loadInfo.to);
    }
  }

  void _updateHitNotes(int ms) {
    for (List<HitNote> hitNotes in _hitNotesByKey) {
      hitNotes.removeWhere((hitNote) {
        hitNote.animationMs += ms;
        return hitNote.animationMs > hitEffectAnimationMs;
      });
    }
  }

  void pause() {
    _frameGenerator?.cancel();
  }

  void replay() {
    _init();
    play();
  }

  void enterKey(int key, bool isDown) {
    final queue = pattern.noteQueues[key];

    if (queue.isEmpty) return;

    final diffMs = queue.first.ms - _currentMs;
    final diffMsForJudgement = diffMs.abs() ~/ 2;

    if (isDown) {
      if (diffMsForJudgement <= missJudgementMs) {
        if (diffMsForJudgement <= perfectJudgementMs) {
          _onPerfect();
        } else {
          _onGood(diffMsForJudgement);
        }

        _hitNoteCount++;
        _accuracy = _accuracySum / _hitNoteCount;
        final note = queue.removeAt(0);
        _hitNotesByKey[note.index].add(HitNote(note.index, diffMs));
      }
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
}

class _LoadInfo {
  final int from;
  final int to;
  final int next;

  const _LoadInfo(this.from, this.to, this.next);
}
