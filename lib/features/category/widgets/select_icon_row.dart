import 'package:flutter/material.dart';

import './icon_selection_dialog.dart';
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color onPrimary = colorScheme.onPrimary;
    final Color primary = colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32,
            child: IconButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(onPrimary),
                foregroundColor: MaterialStateProperty.all(primary),
                iconColor: MaterialStateProperty.all(primary),
              ),
              onPressed: () async {
                await openIconSelectionDialog(context);
                setState(() {});
              },
              icon: widget.iconModel.iconWidget(size: 32),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Selected Icon',
            style: AppTextStyles.textStyleMedium16.copyWith(
              color: primary,
            ),
          ),
          const SizedBox(width: 8),
          ColorButton(
            currentColor: Color(widget.iconModel.iconColor),
            callBack: changeIconColor,
          ),
        ],
      ),
    );
  }
}
