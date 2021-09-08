import 'package:beatrain/note.dart';
import 'package:beatrain/pattern.dart';
import 'package:beatrain/screen/play_screen.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final patterns = <Pattern>[];

  @override
  void initState() {
    super.initState();
    patterns.add(TestPattern());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text("Beatrain"),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final pattern = patterns[index];
          return Card(
            child: ListTile(
              title: Text(pattern.name),
              subtitle: Text("BPM: ${pattern.bpm}"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PlayScreen(pattern: pattern)));
              },
            ),
          );
        },
        itemCount: patterns.length,
      ));
}

class TestPattern extends Pattern {
  static const _bpm = 140;
  TestPattern() : super("Test", _bpm, 6, 30000);

  final interval = (60000 / _bpm) ~/ 2;

  @override
  void loadNotes(int fromMs, int toMs) {
    if (toMs >= 27000 || fromMs < 1500) return;

    int index = 0;
    for (int ms = fromMs; ms < toMs - (interval / 4); ms += interval) {
      final beat = index % 4;

      if (beat % 2 == 0) {
        noteQueues[5].add(Note(5, ms));
        if (beat == 2) {
          noteQueues[4].add(Note(4, ms));
        }
      } else if (beat == 3) {
        noteQueues[0].add(Note(0, ms));
      }

      index++;
    }
  }
}
