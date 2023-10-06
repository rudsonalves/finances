import 'dart:async';

import 'package:flutter/material.dart';

class SpinBoxField extends StatefulWidget {
  final int initialValue;
  final String labelText;
  final TextStyle? style;
  final String? hintText;
  final TextEditingController controller;
  final int flex;
  final int minValue;
  final int maxValue;
  final int increment;
  final String? unit;

  const SpinBoxField({
    super.key,
    this.initialValue = 0,
    required this.labelText,
    this.style,
    this.hintText,
    required this.controller,
    this.flex = 1,
    this.minValue = 0,
    this.maxValue = 10,
    this.increment = 1,
    this.unit,
  });

  @override
  State<SpinBoxField> createState() => _SpinBoxFieldState();
}

class _SpinBoxFieldState extends State<SpinBoxField> {
  late int value;
  Timer? _incrementTimer;
  Timer? _decrementTimer;

  @override
  void initState() {
    super.initState();

    value = widget.initialValue;

    widget.controller.text = 'x $value';
  }

  void _longDecrement() {
    _decrementTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (value > widget.minValue) {
          _decrement();
        } else {
          _decrementTimer?.cancel();
        }
      },
    );
  }

  void _stopDecrement(TapUpDetails details) {
    _decrementTimer?.cancel();
  }

  void _longIncrement() {
    _incrementTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (value < widget.maxValue) {
          _increment();
        } else {
          _incrementTimer?.cancel();
        }
      },
    );
  }

  void _stopIncrement(TapUpDetails details) {
    _incrementTimer?.cancel();
  }

  void _decrement() {
    if (value > widget.minValue) {
      value -= widget.increment;

      widget.controller.text = 'x $value';
    }
  }

  void _increment() {
    if (value < widget.maxValue) {
      value += widget.increment;

      widget.controller.text = 'x $value';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Ink(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _decrement,
                onLongPress: _longDecrement,
                onTapUp: _stopDecrement,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              readOnly: true,
              textAlign: TextAlign.center,
              style: widget.style,
              controller: widget.controller,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: widget.labelText.toUpperCase(),
                hintText: widget.hintText,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Ink(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _increment,
                onLongPress: _longIncrement,
                onTapUp: _stopIncrement,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
