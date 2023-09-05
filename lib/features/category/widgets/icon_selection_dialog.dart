import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../common/models/icons_model.dart';
import '../../../common/constants/themes/app_icons.dart';
import '../../../common/constants/themes/app_text_styles.dart';

class IconSelectionDialog extends StatefulWidget {
  final void Function(IconModel icon) onIconSelected;

  const IconSelectionDialog({
    super.key,
    required this.onIconSelected,
  });

  @override
  State<IconSelectionDialog> createState() => _IconSelectionDialogState();
}

class _IconSelectionDialogState extends State<IconSelectionDialog> {
  late List<String> iconsList;
  late IconsFontFamily fontFamily;

  @override
  void initState() {
    super.initState();
    fontFamily = IconsFontFamily.MaterialIcons;
    iconsList = AppIcons.iconNames(fontFamily);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return StatefulBuilder(
      builder: (context, setState) {
        return SimpleDialog(
          title: Text(locale.iconSelectionDialogIconSelection),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                left: 16,
                right: 16,
              ),
              child: Row(
                children: [
                  Text('${locale.iconSelectionDialogIconFamily}: '),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          switch (fontFamily) {
                            case IconsFontFamily.MaterialIcons:
                              fontFamily = IconsFontFamily.TrademarkIcons;
                              break;
                            case IconsFontFamily.TrademarkIcons:
                              fontFamily = IconsFontFamily.FontelloIcons;
                              break;
                            default:
                              fontFamily = IconsFontFamily.MaterialIcons;
                          }
                          iconsList = AppIcons.iconNames(fontFamily);
                        });
                      },
                      child: Text(
                        fontFamily.name,
                        style: AppTextStyles.textStyleBold14.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
                left: 16,
                right: 16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: locale.iconSelectionDialogSearch,
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          iconsList = AppIcons.iconNames(fontFamily);
                        } else {
                          iconsList = AppIcons.iconNames(fontFamily)
                              .where(
                                (iconName) => iconName.contains(value),
                              )
                              .toList();
                        }
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 22),
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.close_sharp,
                      color: colorScheme.onPrimary,
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        colorScheme.primary,
                      ),
                    ),
                    label: Text(
                      locale.genericClose,
                      style: AppTextStyles.textStyleBold14.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 400,
              width: 300,
              child: GridView.count(
                crossAxisCount: 3,
                children: iconsList
                    .map(
                      (selected) => GestureDetector(
                        onTap: () {
                          widget.onIconSelected(
                            IconModel(
                              iconName: selected,
                              iconFontFamily: fontFamily,
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Icon(
                              AppIcons.iconData(selected, fontFamily),
                              size: 40,
                            ),
                            Text(
                              selected,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.textStyle12,
                            )
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
