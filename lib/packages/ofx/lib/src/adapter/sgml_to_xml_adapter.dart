import 'dart:convert';

sealed class SgmlToXmlAdapter {
  static final _sgmlHeaderPattern = RegExp(
    r'^\s*(OFXHEADER:100|DATA:OFXSGML)\s*$',
    multiLine: true,
    caseSensitive: false,
  );

  static final _tagPattern = RegExp(
    r'<(/?)([a-zA-Z\d_.-]+)>',
  );

  static String normalizeIfNeeded(String source) {
    if (!_sgmlHeaderPattern.hasMatch(source)) {
      return source;
    }

    final ofxStart = source.toUpperCase().indexOf('<OFX>');

    if (ofxStart < 0) {
      throw const FormatException(
        'Documento OFX SGML sem a tag OFX.',
      );
    }

    final body = source.substring(ofxStart);
    final output = StringBuffer();
    const escape = HtmlEscape(HtmlEscapeMode.element);

    final matches = _tagPattern.allMatches(body).toList();

    final explicitlyClosedTags = matches
        .where((match) => match.group(1) == '/')
        .map((match) => match.group(2)!)
        .toSet();

    String? lastOpenTag;
    var cursor = 0;
    var foundTag = false;

    for (final match in matches) {
      foundTag = true;

      final value = body.substring(cursor, match.start).trim();
      final isClosingTag = match.group(1) == '/';
      final tag = match.group(2)!;

      if (value.isNotEmpty && lastOpenTag != null) {
        output.write(escape.convert(value));

        final closesLastOpenTag = isClosingTag && tag == lastOpenTag;

        if (!closesLastOpenTag) {
          output.write('</$lastOpenTag>');
        }
      } else if (lastOpenTag != null &&
          !explicitlyClosedTags.contains(lastOpenTag)) {
        output.write('</$lastOpenTag>');
      }

      if (isClosingTag) {
        output.write('</$tag>');
        lastOpenTag = null;
      } else {
        output.write('<$tag>');
        lastOpenTag = tag;
      }

      cursor = match.end;
    }

    if (!foundTag) {
      throw const FormatException(
        'Documento OFX SGML sem tags válidas.',
      );
    }

    final trailingValue = body.substring(cursor).trim();

    if (trailingValue.isNotEmpty && lastOpenTag != null) {
      output
        ..write(escape.convert(trailingValue))
        ..write('</$lastOpenTag>');
    }

    return output.toString();
  }
}
