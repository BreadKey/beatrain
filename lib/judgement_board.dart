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

  final Stream<Judgement> stream;

  const JudgementBoard({Key? key, required this.stream}) : super(key: key);

  @override
  _JudgementBoardState createState() => _JudgementBoardState();
}

class _JudgementBoardState extends State<JudgementBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<Offset> animation;
  late final StreamSubscription subscription;
  Judgement? judgement;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 50));
    animation = Tween(begin: Offset.zero, end: Offset(0, 0.5)).animate(
        CurvedAnimation(parent: animationController, curve: Curves.ease));

    subscription = widget.stream.listen((judgement) {
      setState(() {
        this.judgement = judgement;
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
      child: Text(
        "${JudgementBoard.kJudgementText[judgement] ?? ''}",
        style:
            style.copyWith(color: JudgementBoard.kJudgementColors[judgement]),
      ),
    );
  }
}
