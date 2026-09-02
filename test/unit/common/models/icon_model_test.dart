import 'package:finances/common/constants/themes/app_icons.dart';
import 'package:finances/common/models/icons_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IconModel serialização', () {
    for (final IconsFontFamily fontFamily in IconsFontFamily.values) {
      test('preserva a família ${fontFamily.name}', () {
        final IconModel source = IconModel(
          iconId: 10,
          iconName: 'test_icon',
          iconFontFamily: fontFamily,
          iconColor: 0xFF123456,
        );

        final IconModel result = IconModel.fromMap(source.toMap());

        expect(result.iconId, source.iconId);
        expect(result.iconName, source.iconName);
        expect(result.iconFontFamily, source.iconFontFamily);
        expect(result.iconColor, source.iconColor);
      });
    }

    test('preserva identificador nulo', () {
      final IconModel source = IconModel(
        iconName: 'test_icon',
        iconFontFamily: IconsFontFamily.MaterialIcons,
      );

      final IconModel result = IconModel.fromMap(source.toMap());

      expect(result.iconId, isNull);
      expect(result.iconName, source.iconName);
      expect(result.iconFontFamily, source.iconFontFamily);
      expect(result.iconColor, source.iconColor);
    });

    test('reconstrói o modelo produzido por toJson', () {
      final IconModel source = IconModel(
        iconId: 10,
        iconName: 'test_icon',
        iconFontFamily: IconsFontFamily.FontelloIcons,
        iconColor: 0xFF123456,
      );

      final IconModel result = IconModel.fromJson(source.toJson());

      expect(result.iconId, source.iconId);
      expect(result.iconName, source.iconName);
      expect(result.iconFontFamily, source.iconFontFamily);
      expect(result.iconColor, source.iconColor);
    });
  });
}
