import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final void Function()? onPressed;

  const CustomFloatingActionButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color primary = Theme.of(context).colorScheme.primary;
    Color onPrimary = Theme.of(context).colorScheme.onPrimary;

    return FloatingActionButton(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      onPressed: onPressed,
      child: const Icon(Icons.add),
    );
  }
}
