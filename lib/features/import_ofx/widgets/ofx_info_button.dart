import 'package:flutter/material.dart';

class OfxInfoButton extends StatefulWidget {
  final String title;
  final String value;
  final void Function() callBack;

  const OfxInfoButton({
    super.key,
    required this.title,
    required this.value,
    required this.callBack,
  });

  @override
  State<OfxInfoButton> createState() => _OfxInfoButtonState();
}

class _OfxInfoButtonState extends State<OfxInfoButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: widget.callBack,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(widget.value),
          ),
        ),
      ],
    );
  }
}
