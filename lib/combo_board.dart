import 'package:beatrain/pattern_player.dart';
import 'package:flutter/material.dart';

class ComboBoard extends StatefulWidget {
  final PatternPlayer patternPlayer;

  const ComboBoard({Key? key, required this.patternPlayer}) : super(key: key);

  @override
  _ComboBoardState createState() => _ComboBoardState();
}

class _ComboBoardState extends State<ComboBoard> {
  late final void Function() listener;
  int? combo;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (combo != widget.patternPlayer.combo) {
        setState(() {
          combo = widget.patternPlayer.combo;
        });
      }
    };
    widget.patternPlayer.addListener(listener);
  }

  @override
  void dispose() {
    widget.patternPlayer.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(
        "${combo == 0 || combo == null ? '' : combo}",
        style: Theme.of(context)
            .textTheme
            .headline1
            ?.copyWith(color: Colors.white60),
      );
}
