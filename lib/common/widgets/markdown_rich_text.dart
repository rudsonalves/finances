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
