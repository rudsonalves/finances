import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../constants/themes/app_button_styles.dart';

class ColorButton extends StatefulWidget {
  final Color currentColor;
  final void Function(Color) callBack;

  const ColorButton({
    super.key,
    required this.currentColor,
    required this.callBack,
  });

  @override
  State<ColorButton> createState() => _ColorButtonState();
}

class _ColorButtonState extends State<ColorButton> {
  late Color pickerColor;

  void changeColor(color) {
    setState(() => pickerColor = color);
    widget.callBack(color);
  }

  @override
  void initState() {
    super.initState();
    pickerColor = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return IconButton(
      tooltip: locale.openColorSelectionDialog,
      onPressed: () async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(locale.colorButtonPickColor),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: changeColor,
              ),
            ),
            actions: [
              ElevatedButton(
                style: AppButtonStyles.primaryButtonColor(context),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(locale.genericClose),
              ),
            ],
          ),
        );
      },
      icon: Icon(
        Icons.radio_button_checked,
        color: pickerColor,
        size: 46,
      ),
    );
  }
}
