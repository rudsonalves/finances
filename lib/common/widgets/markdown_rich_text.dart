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

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../constants/themes/app_text_styles.dart';

class TextItem {
  String text;
  TextStyle textStyle;

  TextItem({
    required this.text,
    required this.textStyle,
  });
}

class MarkdownRichText {
  MarkdownRichText._();

  static RichText richText(
    String text, {
    TextStyle normalStyle = AppTextStyles.textStyle14,
    TextStyle boldStyle = AppTextStyles.textStyleBold14,
    Color? color,
    TextAlign textAlign = TextAlign.start,
  }) {
    List<TextItem> listText = [];

    while (text.contains('**')) {
      int startBoldIndex = text.indexOf('**');
      text = text.replaceFirst('**', '');
      int endBoldIndex = text.indexOf('**');
      text = text.replaceFirst('**', '');

      if (startBoldIndex != 0) {
        listText.add(
          TextItem(
            text: text.substring(0, startBoldIndex),
            textStyle: normalStyle,
          ),
        );
      }
      listText.add(
        TextItem(
          text: text.substring(startBoldIndex, endBoldIndex),
          textStyle: boldStyle,
        ),
      );
      text = text.substring(endBoldIndex);
    }

    if (text.isNotEmpty) {
      listText.add(
        TextItem(
          text: text,
          textStyle: normalStyle,
        ),
      );
    }

    List<InlineSpan> listInlineSpan = [];

    for (final item in listText) {
      listInlineSpan.add(
        TextSpan(
          text: item.text,
          style: item.textStyle.copyWith(color: color),
        ),
      );
    }

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        children: listInlineSpan,
      ),
    );
  }
}
