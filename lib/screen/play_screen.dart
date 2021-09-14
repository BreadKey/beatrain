library play_screen;

import 'package:beatrain/configuration.dart';
import 'package:beatrain/pattern.dart';
import 'package:beatrain/pattern_player.dart';
import 'package:beatrain/screen/note_renderer.dart';
import 'package:beatrain/screen/play_screen/note_screen.dart';
import 'package:beatrain/screen/speed_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayScreen extends StatefulWidget {
  static const kJudgementLineHeight = 50.0;
  static const kJudgementLineThickness = 20.0;
  static const kPixelPerBeat = kJudgementLineThickness * 8;
  final Pattern pattern;
  final bool canPlay;
  final NoteRenderer noteRenderer;

  const PlayScreen(
      {Key? key,
      required this.pattern,
      this.canPlay = true,
      NoteRenderer? noteRenderer,
      double speed = 1.0})
      : this.noteRenderer = noteRenderer ?? const DefaultNoteRenderer(),
        super(key: key);

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
  final configuration = Configuration.instance;

  late final FocusNode focusNode;

  late final List<bool> pressed;

  late void Function(void Function()) setKeyState;

  @override
  void initState() {
    super.initState();

    patternPlayer = PatternPlayer(widget.pattern);
    if (widget.canPlay) {
      RawKeyboard.instance.addListener(onKey);
      patternPlayer.play();
    }

    focusNode = FocusNode();
    pressed = List.generate(patternPlayer.keyLength, (index) => false);
  }

  @override
  void dispose() {
    patternPlayer.dispose();
    focusNode.dispose();
    RawKeyboard.instance.removeListener(onKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: RawKeyboardListener(
          focusNode: focusNode,
          child: Center(
              child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: 80.0 * widget.pattern.keyLength),
            child: Column(children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    buildKeyListener(context),
                    NoteScreen(
                      patternPlayer: patternPlayer,
                      noteRenderer: widget.noteRenderer,
                    )
                  ],
                ),
              ),
              Row(
                children: List.generate(
                    patternPlayer.keyLength,
                    (index) => Expanded(
                        child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.symmetric(
                                  horizontal: BorderSide(
                                      color: Theme.of(context).dividerColor)),
                              color: DefaultNoteRenderer
                                  .kKeyColors[patternPlayer.keyLength]![index],
                            ),
                            child: Text(
                              configuration
                                  .keySettings[patternPlayer.keyLength]![index]
                                  .keyLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  ?.copyWith(color: Colors.black87),
                            )))),
              ),
              widget.canPlay
                  ? SpeedButton(pattern: widget.pattern, focusNode: focusNode)
                  : const SizedBox.shrink()
            ]),
          ))));

  Widget buildKeyListener(BuildContext context) =>
      StatefulBuilder(builder: (context, setKeyState) {
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
      });

  void onKey(RawKeyEvent event) {
    final index = configuration.keySettings[patternPlayer.keyLength]!
        .indexOf(event.logicalKey);

    if (index != -1) {
      enterKey(index, event is RawKeyDownEvent);
    } else if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        patternPlayer.replay();
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        RawKeyboard.instance.removeListener(onKey);
        Navigator.of(context).pop();
      }
    }
  }

  void enterKey(int index, bool isDown) {
    setKeyState(() {
      if (pressed[index] != isDown) {
        patternPlayer.enterKey(index, isDown);
        pressed[index] = isDown;
      }
    });
  }
}
