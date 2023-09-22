import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final locale = AppLocalizations.of(context)!;

    return Semantics(
      label: locale.genericAdd,
      child: FloatingActionButton(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        onPressed: onPressed,
        child: const Icon(Icons.add),
      ),
    );
  }
}
