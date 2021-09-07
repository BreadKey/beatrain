library play_screen;

import 'package:beatrain/configuration.dart';
import 'package:beatrain/screen/note_renderer.dart';
import 'package:beatrain/screen/play_screen/note_screen.dart';
import 'package:beatrain/pattern.dart';
import 'package:beatrain/pattern_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayScreen extends StatefulWidget {
  static const kJudgementLineHeight = 50.0;
  static const kJudgementLineThickness = 20.0;
  static const kPixelPerBeat = kJudgementLineThickness * 8;
  final Pattern pattern;

  const PlayScreen({Key? key, required this.pattern}) : super(key: key);

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  static final kKeyDownColors = DefaultNoteRenderer.kKeyColors.map(
      (keyLength, value) => MapEntry(
          keyLength,
          value.map((keyIndex, color) =>
              MapEntry(keyIndex, color.withOpacity(0.25)))));

  late final PatternPlayer patternPlayer;
  final configuration = Configuration();

  late final FocusNode focusNode;

  late final List<bool> pressed;

  late void Function(void Function()) setKeyState;

  @override
  void initState() {
    super.initState();
    patternPlayer = PatternPlayer(widget.pattern)..play();

    focusNode = FocusNode();
    pressed = List.generate(patternPlayer.keyLength, (index) => false);
  }

  @override
  void dispose() {
    patternPlayer.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
          child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 80.0 * widget.pattern.keyLength),
        child: Column(children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                buildKeyListener(context),
                NoteScreen(patternPlayer: patternPlayer)
              ],
            ),
          ),
          Row(
            children: List.generate(
                patternPlayer.keyLength,
                (index) => Expanded(
                    child: MaterialButton(
                        focusNode: focusNode,
                        color: DefaultNoteRenderer
                            .kKeyColors[patternPlayer.keyLength]![index],
                        textColor: Colors.black87,
                        onPressed: () {},
                        onHighlightChanged: (isDown) {
                          enterKey(index, isDown);
                        },
                        child: Text(configuration
                            .keySettings[patternPlayer.keyLength]![index]
                            .keyLabel)))),
          )
        ]),
      )));

  Widget buildKeyListener(BuildContext context) => RawKeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKey: onKey,
      child: StatefulBuilder(builder: (context, setKeyState) {
        this.setKeyState = setKeyState;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(patternPlayer.keyLength, (keyIndex) {
            return Expanded(
                child: Container(
              decoration: const BoxDecoration(
                  border: Border.symmetric(
                      vertical: BorderSide(color: Colors.white30, width: 1))),
              child: Material(
                color: pressed[keyIndex]
                    ? kKeyDownColors[patternPlayer.keyLength]![keyIndex]
                    : Colors.transparent,
              ),
            ));
          }),
        );
      }));

  void onKey(RawKeyEvent event) {
    final index = configuration.keySettings[patternPlayer.keyLength]!
        .indexOf(event.logicalKey);

    if (index != -1) {
      enterKey(index, event is RawKeyDownEvent);
    } else if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        patternPlayer.speedDown();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        patternPlayer.speedUp();
      } else if (event.logicalKey == LogicalKeyboardKey.space) {
        patternPlayer.replay();
      }
    }
  }

  void enterKey(int index, bool isDown) {
    setKeyState(() {
      pressed[index] = isDown;
      patternPlayer.enterKey(index);
    });
  }
}
