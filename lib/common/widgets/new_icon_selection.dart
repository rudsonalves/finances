// Copyright (C) 2024 rudson
//
// This file is part of finances.
//
// finances is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// finances is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with finances.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';

import '../constants/themes/app_icons.dart';
import '../constants/themes/app_text_styles.dart';
import '../models/icons_model.dart';

const List<Color> paintColors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.yellow,
  // Colors.orange,
  Colors.cyan,
  Colors.indigo,
];

class NewIconSelection extends StatefulWidget {
  final IconModel? icon;

  const NewIconSelection({
    super.key,
    this.icon,
  });

  @override
  State<NewIconSelection> createState() => _NewIconSelectionState();
}

class _NewIconSelectionState extends State<NewIconSelection> {
  int? iconId;
  final _iconName = ValueNotifier<String>('attach money');
  final _iconFontFamily = ValueNotifier<IconsFontFamily>(
    IconsFontFamily.MaterialIcons,
  );
  final _iconColor = ValueNotifier<int>(0xFF14A01B);
  final _iconSearch = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    IconModel? icon = widget.icon;
    if (icon != null) {
      iconId = icon.iconId;
      _iconName.value = icon.iconName;
      _iconFontFamily.value = icon.iconFontFamily;
      _iconColor.value = icon.iconColor;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _iconName.dispose();
    _iconFontFamily.dispose();
    _iconColor.dispose();
    _iconSearch.dispose();
  }

  Icon get mountIcon {
    final iconModel = IconModel(
      iconName: _iconName.value,
      iconFontFamily: _iconFontFamily.value,
      iconColor: _iconColor.value,
    );
    return iconModel.iconWidget(size: 32);
  }

  void _changeColorButton() async {
    Color pickerColor = Color(_iconColor.value);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) {
              pickerColor = color;
            },
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Select'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (result != null && result == true) {
      _iconColor.value = pickerColor.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primary;
    int iconsPerPage = 25;
    int iconsColumns = 5;
    List<String> iconsList = AppIcons.iconNames(_iconFontFamily.value);
    int numberOfPages = (iconsList.length / iconsPerPage).ceil();
    final screenSize = MediaQuery.of(context).size;
    double cardIconHeight =
        (58 * iconsPerPage / iconsColumns + 20) * screenSize.width / 384;
    if (screenSize.width >= 800) {
      iconsPerPage = 40;
      iconsColumns = 10;
      cardIconHeight =
          (72 * iconsPerPage / iconsColumns + 20) * screenSize.width / 800;
    } else if (screenSize.width >= 600) {
      iconsPerPage = 40;
      iconsColumns = 10;
      cardIconHeight =
          (56 * iconsPerPage / iconsColumns + 20) * screenSize.width / 600;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                locale.iconSelectionDialogIconSelection,
                style: AppTextStyles.textStyleSemiBold20.copyWith(
                  color: primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // FontFamily
            Center(
              child: OutlinedButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                onPressed: () {
                  switch (_iconFontFamily.value) {
                    case IconsFontFamily.MaterialIcons:
                      _iconFontFamily.value = IconsFontFamily.TrademarkIcons;
                      break;
                    case IconsFontFamily.TrademarkIcons:
                      _iconFontFamily.value = IconsFontFamily.FontelloIcons;
                      break;
                    default:
                      _iconFontFamily.value = IconsFontFamily.MaterialIcons;
                  }
                  iconsList = AppIcons.iconNames(_iconFontFamily.value);
                },
                child: ListenableBuilder(
                    listenable: _iconFontFamily,
                    builder: (context, _) {
                      return Text(
                        _iconFontFamily.value.name,
                        style: AppTextStyles.textStyleBold14.copyWith(
                          color: colorScheme.primary,
                        ),
                      );
                    }),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.filter_alt_outlined),
                const SizedBox(width: 4),
                // Search
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: locale.iconSelectionDialogSearch,
                    ),
                    onChanged: (value) {
                      _iconSearch.value = value;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Icon View
                ListenableBuilder(
                  listenable: Listenable.merge([_iconName, _iconColor]),
                  builder: (context, _) {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: _changeColorButton,
                          child: SizedBox(
                            height: 52,
                            // width: 52,
                            child: mountIcon,
                          ),
                        ),
                        Text(
                          _iconName.value,
                          style: AppTextStyles.textStyle10,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            // Icon Grid
            const SizedBox(height: 12),
            SizedBox(
              height: cardIconHeight,
              child: Card(
                color: colorScheme.onInverseSurface,
                child: ListenableBuilder(
                  listenable: Listenable.merge([_iconFontFamily, _iconSearch]),
                  builder: (context, _) {
                    iconsList = AppIcons.iconNames(_iconFontFamily.value);
                    final search = _iconSearch.value.toLowerCase();
                    if (search != '') {
                      iconsList = iconsList
                          .where(
                            (element) => element.toLowerCase().contains(search),
                          )
                          .toList();
                    }
                    numberOfPages = (iconsList.length / iconsPerPage).ceil();
                    return Swiper(
                      itemCount: numberOfPages,
                      pagination: SwiperPagination(
                        builder: DotSwiperPaginationBuilder(
                          color: colorScheme.outline,
                          activeColor: Colors.purple,
                        ),
                      ),
                      itemBuilder: (context, indexPage) {
                        final startIndex = indexPage * iconsPerPage;
                        int endIndex = (indexPage + 1) * iconsPerPage;
                        if (endIndex > iconsList.length) {
                          endIndex = iconsList.length;
                        }

                        List<Icon> iconsToShow =
                            iconsList.sublist(startIndex, endIndex).map(
                          (name) {
                            return IconModel(
                              iconName: name,
                              iconFontFamily: _iconFontFamily.value,
                              iconColor: 0xFF000000,
                            ).iconWidget(size: 24);
                          },
                        ).toList();

                        return GridView.builder(
                          itemCount: iconsToShow.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: iconsColumns,
                          ),
                          itemBuilder: (context, index) => InkWell(
                            child: iconsToShow[index],
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              _iconName.value =
                                  iconsList[index + indexPage * iconsPerPage];
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            // Colors Buttons
            const SizedBox(height: 12),
            Text(
              locale.iconSelectionDialogColors,
              style: AppTextStyles.textStyleSemiBold18.copyWith(
                color: primary,
              ),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.start,
              children: [
                IconButton.filled(
                    onPressed: _changeColorButton,
                    icon: const Icon(Icons.format_paint_sharp)),
                for (final color in paintColors)
                  InkWell(
                    onTap: () {
                      _iconColor.value = color.value;
                    },
                    child: Icon(
                      Icons.fiber_manual_record,
                      color: color,
                      size: 24,
                    ),
                  ),
              ],
            ),
            // Buttons
            const SizedBox(height: 12),
            OverflowBar(
              children: [
                FilledButton(
                  onPressed: () {
                    IconModel newIcon = IconModel(
                      iconId: iconId,
                      iconName: _iconName.value,
                      iconFontFamily: _iconFontFamily.value,
                      iconColor: _iconColor.value,
                    );

                    Navigator.of(context).pop(newIcon);
                  },
                  child: Text(locale.genericSelect),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(locale.accountPageCancel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
