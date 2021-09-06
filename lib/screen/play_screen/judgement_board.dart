import 'dart:async';

import 'package:beatrain/pattern_player.dart';
import 'package:flutter/material.dart';

class JudgementBoard extends StatefulWidget {
  static final kJudgementColors = {
    Judgement.miss: Colors.redAccent.withOpacity(0.5),
    Judgement.good: Colors.blueAccent.withOpacity(0.5),
    Judgement.perfect: Colors.amberAccent.withOpacity(0.5)
  };
  static final kJudgementText = {
    Judgement.miss: "Miss",
    Judgement.good: "Good",
    Judgement.perfect: "Perfect"
  };

  final PatternPlayer patternPlayer;

  const JudgementBoard({Key? key, required this.patternPlayer})
      : super(key: key);

  @override
  _JudgementBoardState createState() => _JudgementBoardState();
}

class _JudgementBoardState extends State<JudgementBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<Offset> animation;
  late final StreamSubscription subscription;
  Judgement? judgement;
  int? combo;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50));
    animation = Tween(begin: Offset.zero, end: Offset(0, 0.01)).animate(
        CurvedAnimation(parent: animationController, curve: Curves.ease));

    subscription = widget.patternPlayer.judgementStream.listen((judgement) {
      setState(() {
        this.judgement = judgement;
        this.combo = widget.patternPlayer.combo;
      });
      animationController.forward(from: 0);
    });
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headline6!;
    return SlideTransition(
        position: animation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                child: Align(
              alignment: Alignment(0, -0.618),
              child: Text(
                "${combo == 0 || combo == null ? '' : combo}",
                style: Theme.of(context)
                    .textTheme
                    .headline1
                    ?.copyWith(color: Colors.white60),
              ),
            )),
            Text(
              (widget.patternPlayer.accuracy * 100).toStringAsFixed(2),
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(color: Colors.white70),
            ),
            Text(
              "${JudgementBoard.kJudgementText[judgement] ?? ''}",
              style: style.copyWith(
                  color: JudgementBoard.kJudgementColors[judgement]),
            ),
          ],
        ));
  }
}
