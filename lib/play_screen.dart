import 'package:beatrain/configuration.dart';
import 'package:beatrain/pattern.dart';
import 'package:beatrain/pattern_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayScreen extends StatefulWidget {
  final Pattern pattern;

  const PlayScreen({Key? key, required this.pattern}) : super(key: key);

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final PatternPlayer patternPlayer;
  late final FocusNode focusNode;

  late final List<bool> pressDown;
  final configuration = Configuration();

  @override
  void initState() {
    super.initState();
    patternPlayer = PatternPlayer(widget.pattern)..play();
    focusNode = FocusNode();
    pressDown = List.generate(widget.pattern.keyLength, (index) => false);
  }

  @override
  void dispose() {
    patternPlayer.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, contsraints) => RawKeyboardListener(
          autofocus: true,
          focusNode: focusNode,
          onKey: onKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(widget.pattern.keyLength * 2 + 1, (index) {
              final keyIndex = index ~/ 2;
              return index % 2 == 1
                  ? Expanded(
                      child: Material(
                      color: pressDown[keyIndex]
                          ? Colors.blue
                          : Colors.transparent,
                      child: Stack(
                          children: List.generate(
                              widget.pattern.noteQueues[keyIndex].length,
                              (index) => Container(
                                    height: 10,
                                    width: double.infinity,
                                    color: Colors.white,
                                  ))),
                    ))
                  : const VerticalDivider();
            }),
          )));

  void onKey(RawKeyEvent event) {
    final index = configuration.keySettings[widget.pattern.keyLength]!
        .indexOf(event.logicalKey);

    if (index != -1) {
      setState(() {
        pressDown[index] = event is RawKeyDownEvent;
      });
    }
  }
}
