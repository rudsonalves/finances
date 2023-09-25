import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'icon_selection_dialog.dart';
import '../../../common/models/icons_model.dart';
import '../../../common/widgets/color_button.dart';
import '../../../common/constants/themes/app_text_styles.dart';

class SelectIconRow extends StatefulWidget {
  final IconModel iconModel;
  final void Function(IconModel) iconCallback;

  const SelectIconRow({
    super.key,
    required this.iconModel,
    required this.iconCallback,
  });

  @override
  State<SelectIconRow> createState() => _SelectIconRowState();
}

class _SelectIconRowState extends State<SelectIconRow> {
  @override
  void initState() {
    super.initState();
  }

  void changeIconColor(Color color) {
    widget.iconModel.iconColor = color.value;
    setState(() {});
  }

  Future<void> openIconSelectionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return IconSelectionDialog(
          onIconSelected: onIconSelected,
        );
      },
    );
  }

  void onIconSelected(IconModel icon) {
    setState(() {
      widget.iconCallback(icon);
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    final primary = colorScheme.primary;
    final locale = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              locale.selectionIconRowQuestion,
              style: AppTextStyles.textStyleSemiBold14.copyWith(
                color: primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                child: IconButton(
                  tooltip: locale.openIconSelectionDialog,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(onPrimary),
                    foregroundColor: MaterialStateProperty.all(primary),
                    iconColor: MaterialStateProperty.all(primary),
                  ),
                  onPressed: () async {
                    await openIconSelectionDialog(context);
                    setState(() {});
                  },
                  icon: widget.iconModel.iconWidget(size: 24),
                ),
              ),
              const SizedBox(width: 50),
              ColorButton(
                currentColor: Color(widget.iconModel.iconColor),
                callBack: changeIconColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
