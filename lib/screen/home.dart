import 'package:beatrain/note.dart';
import 'package:beatrain/pattern.dart';
import 'package:beatrain/screen/home/pattern_tile.dart';
import 'package:beatrain/screen/play_screen.dart';
import 'package:beatrain/screen/speed_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final patterns = <Pattern>[];
  Pattern? selectedPattern;

  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    patterns.addAll([TestPattern(), TestPattern2()]);
    selectedPattern = patterns[0];
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const contentPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 4);

    return Scaffold(
        appBar: AppBar(
          title: Text("Beatrain"),
        ),
        body: RawKeyboardListener(
            focusNode: focusNode,
            autofocus: true,
            onKey: (event) {
              if (event is RawKeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.space) {
                play();
              }
            },
            child: Padding(
              padding: contentPadding,
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(
                    child: Row(
                  children: [
                    Expanded(
                        flex: 1618,
                        child: ListView.builder(
                          itemBuilder: (context, index) {
                            final pattern = patterns[index];
                            return Transform.scale(
                                scale: pattern == selectedPattern ? 1 : 0.98,
                                child: PatternTile(
                                    pattern: pattern,
                                    onTap: () {
                                      setState(() {
                                        selectedPattern = pattern;
                                      });
                                    }));
                          },
                          itemCount: patterns.length,
                        )),
                    const VerticalDivider(),
                    Expanded(
                      flex: 1000,
                      child: Column(
                        children: [
                          Expanded(
                            child: Card(
                                child: Padding(
                              padding: contentPadding,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Note Skin",
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                    ),
                                    Expanded(
                                        child: Row(
                                      children: [
                                        IconButton(
                                            onPressed: null,
                                            icon: const Icon(
                                                Icons.keyboard_arrow_left)),
                                        Expanded(
                                            child: PlayScreen(
                                          key: ValueKey(
                                              selectedPattern?.keyLength),
                                          pattern: _PatternForNoteRenderer(
                                              selectedPattern?.keyLength ?? 4),
                                          canPlay: false,
                                        )),
                                        IconButton(
                                            onPressed: null,
                                            icon: const Icon(
                                                Icons.keyboard_arrow_right)),
                                      ],
                                    ))
                                  ]),
                            )),
                          ),
                          const Divider(),
                          Row(
                            children: [
                              Expanded(
                                  child: SpeedButton(
                                focusNode: focusNode,
                                pattern: selectedPattern,
                              ))
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                )),
                const Divider(),
                TextButton.icon(
                    onPressed: selectedPattern == null ? null : play,
                    icon: const Icon(Icons.keyboard_return),
                    label: Text("Play"))
              ]),
            )));
  }

  void play() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlayScreen(pattern: selectedPattern!)));
  }
}

class TestPattern extends Pattern {
  static const _bpm = 140;
  TestPattern() : super("Test", _bpm, 6, 11, 30000);

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

class TestPattern2 extends Pattern {
  static const _bpm = 180;
  TestPattern2() : super("Trill", _bpm, 6, 11, 5000);

  final _interval = (60000 / _bpm) ~/ 4;

  @override
  void loadNotes(int fromMs, int toMs) {
    for (int index = 0; index < (4 * 12); index++) {
      final keyIndex = (index % 2) == 0 ? 0 : 5;
      noteQueues[keyIndex]
          .add(Note(keyIndex, _interval * 8 + _interval * index));
    }
  }
}

class _PatternForNoteRenderer extends Pattern {
  _PatternForNoteRenderer(int keyLength) : super("", 60, keyLength, 0, 0);

  @override
  void loadNotes(int fromMs, int toMs) {
    for (int index = 0; index < keyLength; index++) {
      noteQueues[index].add(Note(index, 1000 + 250 * (index)));
    }
  }
}
