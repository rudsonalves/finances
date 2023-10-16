import 'package:flutter/material.dart';

class WidgetAlertDialog extends StatelessWidget {
  final String title;
  final List<Widget> content;

  const WidgetAlertDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...content,
        ],
      ),
    );
  }
}
