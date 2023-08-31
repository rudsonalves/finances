import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RowOfTwoBottons extends StatefulWidget {
  final bool income;
  final Function(bool state) changeState;

  const RowOfTwoBottons({
    super.key,
    required this.income,
    required this.changeState,
  });

  @override
  State<RowOfTwoBottons> createState() => _RowOfTwoBottonsState();
}

class _RowOfTwoBottonsState extends State<RowOfTwoBottons> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                widget.income
                    ? colorScheme.secondaryContainer
                    : colorScheme.onInverseSurface,
              ),
            ),
            onPressed: () {
              widget.changeState(true);
            },
            child: Text(locale.rowOfTwoBottonsIncome),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                widget.income
                    ? colorScheme.onInverseSurface
                    : colorScheme.secondaryContainer,
              ),
            ),
            onPressed: () {
              widget.changeState(false);
            },
            child: Text(locale.rowOfTwoBottonsExpense),
          ),
        ),
      ],
    );
  }
}
