import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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

    return ElevatedButton(
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
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(50, 50),
        shape: const CircleBorder(),
      ),
      child: CircleAvatar(
        radius: 32,
        backgroundColor: pickerColor,
      ),
    );
  }
}
