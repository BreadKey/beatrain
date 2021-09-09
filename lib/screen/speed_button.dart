import 'package:beatrain/pattern.dart';
import 'package:beatrain/speed_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpeedButton extends StatefulWidget {
  final FocusNode focusNode;
  final Pattern? pattern;

  const SpeedButton({Key? key, required this.pattern, required this.focusNode})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SpeedButtonState();
}

class _SpeedButtonState extends State<SpeedButton> {
  final _speedManager = SpeedManager.instance;
  double? _speed;

  @override
  void initState() {
    super.initState();
    _init();
    widget.focusNode.addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (widget.focusNode.hasFocus) {
      _attachKeyboardIfDetached();
      _init();
    } else
      _detachKeyboardIfAttached();
  }

  bool _listening = false;

  void _attachKeyboardIfDetached() {
    if (_listening) return;
    RawKeyboard.instance.addListener(_onKey);
    _listening = true;
  }

  void _detachKeyboardIfAttached() {
    if (!_listening) return;
    RawKeyboard.instance.removeListener(_onKey);
    _listening = false;
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocusChanged);
    _detachKeyboardIfAttached();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SpeedButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.pattern != widget.pattern) {
      _init();
    }
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      widget.focusNode.addListener(_handleFocusChanged);
    }
  }

  Future _init() async {
    if (widget.pattern != null) {
      _speed = await _speedManager.currentSpeedOf(widget.pattern!);
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          title: Text("Speed"),
          subtitle: Stack(
            alignment: Alignment.center,
            children: [
              Text("x${_speed?.toStringAsFixed(2) ?? ''}",
                  style: Theme.of(context).textTheme.headline6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  MaterialButton(
                      padding: EdgeInsets.only(top: 0, bottom: 12),
                      child: const Icon(Icons.keyboard_arrow_up),
                      onPressed: _speed == null ? null : _speedUp),
                  MaterialButton(
                      padding: EdgeInsets.only(top: 12, bottom: 0),
                      child: const Icon(Icons.keyboard_arrow_down),
                      onPressed: _speed == null ? null : _speedDown)
                ],
              )
            ],
          ),
        ),
      );

  void _speedUp() {
    _speedManager.speedUp(widget.pattern!);
    setState(() {
      _speed = _speedManager.cachedSpeedOf(widget.pattern!);
    });
  }

  void _speedDown() {
    _speedManager.speedDown(widget.pattern!);
    setState(() {
      _speed = _speedManager.cachedSpeedOf(widget.pattern!);
    });
  }

  void _onKey(RawKeyEvent event) {
    if (_speed == null) return;
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _speedUp();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _speedDown();
      }
    }
  }
}
