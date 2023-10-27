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
          child: TextButton.icon(
            icon: widget.income
                ? const Icon(Icons.task_alt)
                : const Icon(Icons.radio_button_unchecked),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                widget.income
                    ? colorScheme.secondaryContainer
                    : Colors.transparent,
              ),
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              widget.changeState(true);
            },
            label: Text(locale.rowOfTwoBottonsIncome),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextButton.icon(
            icon: !widget.income
                ? const Icon(Icons.task_alt)
                : const Icon(Icons.radio_button_unchecked),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                widget.income
                    ? Colors.transparent
                    : colorScheme.secondaryContainer,
              ),
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              widget.changeState(false);
            },
            label: Text(locale.rowOfTwoBottonsExpense),
          ),
        ),
      ],
    );
  }
}
