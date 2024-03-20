import 'package:flutter/material.dart';

class OfxInformation extends StatelessWidget {
  final String title;
  final String value;

  const OfxInformation({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(value),
        ),
      ],
    );
  }
}
