import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

const lowgreen = Color(0xFFD2FFD3);
const subprimary = Color(0xFFD5D7FF);
const subtertiary = Color(0xFFF8A9F4);
const mediumprimary = Color(0xFF7D84C6);
const minusred = Color(0xFFF73224);
const lightblue = Color(0xFFA1D1FE);
const lightgreen = Color(0xFF93DD41);
const lightyellow = Color(0xFFFFCE52);


CustomColors lightCustomColors = const CustomColors(
  sourceLowgreen: Color(0xFFD2FFD3),
  lowgreen: Color(0xFF166D33),
  onLowgreen: Color(0xFFFFFFFF),
  lowgreenContainer: Color(0xFFA1F6AC),
  onLowgreenContainer: Color(0xFF002109),
  sourceSubprimary: Color(0xFFD5D7FF),
  subprimary: Color(0xFF4E57A9),
  onSubprimary: Color(0xFFFFFFFF),
  subprimaryContainer: Color(0xFFDFE0FF),
  onSubprimaryContainer: Color(0xFF010965),
  sourceSubtertiary: Color(0xFFF8A9F4),
  subtertiary: Color(0xFF884588),
  onSubtertiary: Color(0xFFFFFFFF),
  subtertiaryContainer: Color(0xFFFFD6F9),
  onSubtertiaryContainer: Color(0xFF37003B),
  sourceMediumprimary: Color(0xFF7D84C6),
  mediumprimary: Color(0xFF4D57A9),
  onMediumprimary: Color(0xFFFFFFFF),
  mediumprimaryContainer: Color(0xFFDFE0FF),
  onMediumprimaryContainer: Color(0xFF000965),
  sourceMinusred: Color(0xFFF73224),
  minusred: Color(0xFFC00003),
  onMinusred: Color(0xFFFFFFFF),
  minusredContainer: Color(0xFFFFDAD5),
  onMinusredContainer: Color(0xFF410000),
  sourceLightblue: Color(0xFFA1D1FE),
  lightblue: Color(0xFF006398),
  onLightblue: Color(0xFFFFFFFF),
  lightblueContainer: Color(0xFFCDE5FF),
  onLightblueContainer: Color(0xFF001D32),
  sourceLightgreen: Color(0xFF93DD41),
  lightgreen: Color(0xFF3D6A00),
  onLightgreen: Color(0xFFFFFFFF),
  lightgreenContainer: Color(0xFFABF859),
  onLightgreenContainer: Color(0xFF0F2000),
  sourceLightyellow: Color(0xFFFFCE52),
  lightyellow: Color(0xFF775A00),
  onLightyellow: Color(0xFFFFFFFF),
  lightyellowContainer: Color(0xFFFFDF98),
  onLightyellowContainer: Color(0xFF251A00),
);

CustomColors darkCustomColors = const CustomColors(
  sourceLowgreen: Color(0xFFD2FFD3),
  lowgreen: Color(0xFF86D992),
  onLowgreen: Color(0xFF003915),
  lowgreenContainer: Color(0xFF005322),
  onLowgreenContainer: Color(0xFFA1F6AC),
  sourceSubprimary: Color(0xFFD5D7FF),
  subprimary: Color(0xFFBDC2FF),
  onSubprimary: Color(0xFF1D2678),
  subprimaryContainer: Color(0xFF353E90),
  onSubprimaryContainer: Color(0xFFDFE0FF),
  sourceSubtertiary: Color(0xFFF8A9F4),
  subtertiary: Color(0xFFFBACF7),
  onSubtertiary: Color(0xFF531356),
  subtertiaryContainer: Color(0xFF6D2D6F),
  onSubtertiaryContainer: Color(0xFFFFD6F9),
  sourceMediumprimary: Color(0xFF7D84C6),
  mediumprimary: Color(0xFFBDC2FF),
  onMediumprimary: Color(0xFF1C2678),
  mediumprimaryContainer: Color(0xFF353E90),
  onMediumprimaryContainer: Color(0xFFDFE0FF),
  sourceMinusred: Color(0xFFF73224),
  minusred: Color(0xFFFFB4A8),
  onMinusred: Color(0xFF690001),
  minusredContainer: Color(0xFF930002),
  onMinusredContainer: Color(0xFFFFDAD5),
  sourceLightblue: Color(0xFFA1D1FE),
  lightblue: Color(0xFF94CCFF),
  onLightblue: Color(0xFF003352),
  lightblueContainer: Color(0xFF004B74),
  onLightblueContainer: Color(0xFFCDE5FF),
  sourceLightgreen: Color(0xFF93DD41),
  lightgreen: Color(0xFF91DA3F),
  onLightgreen: Color(0xFF1D3700),
  lightgreenContainer: Color(0xFF2C5000),
  onLightgreenContainer: Color(0xFFABF859),
  sourceLightyellow: Color(0xFFFFCE52),
  lightyellow: Color(0xFFF0C045),
  onLightyellow: Color(0xFF3F2E00),
  lightyellowContainer: Color(0xFF5A4300),
  onLightyellowContainer: Color(0xFFFFDF98),
);



/// Defines a set of custom colors, each comprised of 4 complementary tones.
///
/// See also:
///   * <https://m3.material.io/styles/color/the-color-system/custom-colors>
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.sourceLowgreen,
    required this.lowgreen,
    required this.onLowgreen,
    required this.lowgreenContainer,
    required this.onLowgreenContainer,
    required this.sourceSubprimary,
    required this.subprimary,
    required this.onSubprimary,
    required this.subprimaryContainer,
    required this.onSubprimaryContainer,
    required this.sourceSubtertiary,
    required this.subtertiary,
    required this.onSubtertiary,
    required this.subtertiaryContainer,
    required this.onSubtertiaryContainer,
    required this.sourceMediumprimary,
    required this.mediumprimary,
    required this.onMediumprimary,
    required this.mediumprimaryContainer,
    required this.onMediumprimaryContainer,
    required this.sourceMinusred,
    required this.minusred,
    required this.onMinusred,
    required this.minusredContainer,
    required this.onMinusredContainer,
    required this.sourceLightblue,
    required this.lightblue,
    required this.onLightblue,
    required this.lightblueContainer,
    required this.onLightblueContainer,
    required this.sourceLightgreen,
    required this.lightgreen,
    required this.onLightgreen,
    required this.lightgreenContainer,
    required this.onLightgreenContainer,
    required this.sourceLightyellow,
    required this.lightyellow,
    required this.onLightyellow,
    required this.lightyellowContainer,
    required this.onLightyellowContainer,
  });

  final Color? sourceLowgreen;
  final Color? lowgreen;
  final Color? onLowgreen;
  final Color? lowgreenContainer;
  final Color? onLowgreenContainer;
  final Color? sourceSubprimary;
  final Color? subprimary;
  final Color? onSubprimary;
  final Color? subprimaryContainer;
  final Color? onSubprimaryContainer;
  final Color? sourceSubtertiary;
  final Color? subtertiary;
  final Color? onSubtertiary;
  final Color? subtertiaryContainer;
  final Color? onSubtertiaryContainer;
  final Color? sourceMediumprimary;
  final Color? mediumprimary;
  final Color? onMediumprimary;
  final Color? mediumprimaryContainer;
  final Color? onMediumprimaryContainer;
  final Color? sourceMinusred;
  final Color? minusred;
  final Color? onMinusred;
  final Color? minusredContainer;
  final Color? onMinusredContainer;
  final Color? sourceLightblue;
  final Color? lightblue;
  final Color? onLightblue;
  final Color? lightblueContainer;
  final Color? onLightblueContainer;
  final Color? sourceLightgreen;
  final Color? lightgreen;
  final Color? onLightgreen;
  final Color? lightgreenContainer;
  final Color? onLightgreenContainer;
  final Color? sourceLightyellow;
  final Color? lightyellow;
  final Color? onLightyellow;
  final Color? lightyellowContainer;
  final Color? onLightyellowContainer;

  @override
  CustomColors copyWith({
    Color? sourceLowgreen,
    Color? lowgreen,
    Color? onLowgreen,
    Color? lowgreenContainer,
    Color? onLowgreenContainer,
    Color? sourceSubprimary,
    Color? subprimary,
    Color? onSubprimary,
    Color? subprimaryContainer,
    Color? onSubprimaryContainer,
    Color? sourceSubtertiary,
    Color? subtertiary,
    Color? onSubtertiary,
    Color? subtertiaryContainer,
    Color? onSubtertiaryContainer,
    Color? sourceMediumprimary,
    Color? mediumprimary,
    Color? onMediumprimary,
    Color? mediumprimaryContainer,
    Color? onMediumprimaryContainer,
    Color? sourceMinusred,
    Color? minusred,
    Color? onMinusred,
    Color? minusredContainer,
    Color? onMinusredContainer,
    Color? sourceLightblue,
    Color? lightblue,
    Color? onLightblue,
    Color? lightblueContainer,
    Color? onLightblueContainer,
    Color? sourceLightgreen,
    Color? lightgreen,
    Color? onLightgreen,
    Color? lightgreenContainer,
    Color? onLightgreenContainer,
    Color? sourceLightyellow,
    Color? lightyellow,
    Color? onLightyellow,
    Color? lightyellowContainer,
    Color? onLightyellowContainer,
  }) {
    return CustomColors(
      sourceLowgreen: sourceLowgreen ?? this.sourceLowgreen,
      lowgreen: lowgreen ?? this.lowgreen,
      onLowgreen: onLowgreen ?? this.onLowgreen,
      lowgreenContainer: lowgreenContainer ?? this.lowgreenContainer,
      onLowgreenContainer: onLowgreenContainer ?? this.onLowgreenContainer,
      sourceSubprimary: sourceSubprimary ?? this.sourceSubprimary,
      subprimary: subprimary ?? this.subprimary,
      onSubprimary: onSubprimary ?? this.onSubprimary,
      subprimaryContainer: subprimaryContainer ?? this.subprimaryContainer,
      onSubprimaryContainer: onSubprimaryContainer ?? this.onSubprimaryContainer,
      sourceSubtertiary: sourceSubtertiary ?? this.sourceSubtertiary,
      subtertiary: subtertiary ?? this.subtertiary,
      onSubtertiary: onSubtertiary ?? this.onSubtertiary,
      subtertiaryContainer: subtertiaryContainer ?? this.subtertiaryContainer,
      onSubtertiaryContainer: onSubtertiaryContainer ?? this.onSubtertiaryContainer,
      sourceMediumprimary: sourceMediumprimary ?? this.sourceMediumprimary,
      mediumprimary: mediumprimary ?? this.mediumprimary,
      onMediumprimary: onMediumprimary ?? this.onMediumprimary,
      mediumprimaryContainer: mediumprimaryContainer ?? this.mediumprimaryContainer,
      onMediumprimaryContainer: onMediumprimaryContainer ?? this.onMediumprimaryContainer,
      sourceMinusred: sourceMinusred ?? this.sourceMinusred,
      minusred: minusred ?? this.minusred,
      onMinusred: onMinusred ?? this.onMinusred,
      minusredContainer: minusredContainer ?? this.minusredContainer,
      onMinusredContainer: onMinusredContainer ?? this.onMinusredContainer,
      sourceLightblue: sourceLightblue ?? this.sourceLightblue,
      lightblue: lightblue ?? this.lightblue,
      onLightblue: onLightblue ?? this.onLightblue,
      lightblueContainer: lightblueContainer ?? this.lightblueContainer,
      onLightblueContainer: onLightblueContainer ?? this.onLightblueContainer,
      sourceLightgreen: sourceLightgreen ?? this.sourceLightgreen,
      lightgreen: lightgreen ?? this.lightgreen,
      onLightgreen: onLightgreen ?? this.onLightgreen,
      lightgreenContainer: lightgreenContainer ?? this.lightgreenContainer,
      onLightgreenContainer: onLightgreenContainer ?? this.onLightgreenContainer,
      sourceLightyellow: sourceLightyellow ?? this.sourceLightyellow,
      lightyellow: lightyellow ?? this.lightyellow,
      onLightyellow: onLightyellow ?? this.onLightyellow,
      lightyellowContainer: lightyellowContainer ?? this.lightyellowContainer,
      onLightyellowContainer: onLightyellowContainer ?? this.onLightyellowContainer,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      sourceLowgreen: Color.lerp(sourceLowgreen, other.sourceLowgreen, t),
      lowgreen: Color.lerp(lowgreen, other.lowgreen, t),
      onLowgreen: Color.lerp(onLowgreen, other.onLowgreen, t),
      lowgreenContainer: Color.lerp(lowgreenContainer, other.lowgreenContainer, t),
      onLowgreenContainer: Color.lerp(onLowgreenContainer, other.onLowgreenContainer, t),
      sourceSubprimary: Color.lerp(sourceSubprimary, other.sourceSubprimary, t),
      subprimary: Color.lerp(subprimary, other.subprimary, t),
      onSubprimary: Color.lerp(onSubprimary, other.onSubprimary, t),
      subprimaryContainer: Color.lerp(subprimaryContainer, other.subprimaryContainer, t),
      onSubprimaryContainer: Color.lerp(onSubprimaryContainer, other.onSubprimaryContainer, t),
      sourceSubtertiary: Color.lerp(sourceSubtertiary, other.sourceSubtertiary, t),
      subtertiary: Color.lerp(subtertiary, other.subtertiary, t),
      onSubtertiary: Color.lerp(onSubtertiary, other.onSubtertiary, t),
      subtertiaryContainer: Color.lerp(subtertiaryContainer, other.subtertiaryContainer, t),
      onSubtertiaryContainer: Color.lerp(onSubtertiaryContainer, other.onSubtertiaryContainer, t),
      sourceMediumprimary: Color.lerp(sourceMediumprimary, other.sourceMediumprimary, t),
      mediumprimary: Color.lerp(mediumprimary, other.mediumprimary, t),
      onMediumprimary: Color.lerp(onMediumprimary, other.onMediumprimary, t),
      mediumprimaryContainer: Color.lerp(mediumprimaryContainer, other.mediumprimaryContainer, t),
      onMediumprimaryContainer: Color.lerp(onMediumprimaryContainer, other.onMediumprimaryContainer, t),
      sourceMinusred: Color.lerp(sourceMinusred, other.sourceMinusred, t),
      minusred: Color.lerp(minusred, other.minusred, t),
      onMinusred: Color.lerp(onMinusred, other.onMinusred, t),
      minusredContainer: Color.lerp(minusredContainer, other.minusredContainer, t),
      onMinusredContainer: Color.lerp(onMinusredContainer, other.onMinusredContainer, t),
      sourceLightblue: Color.lerp(sourceLightblue, other.sourceLightblue, t),
      lightblue: Color.lerp(lightblue, other.lightblue, t),
      onLightblue: Color.lerp(onLightblue, other.onLightblue, t),
      lightblueContainer: Color.lerp(lightblueContainer, other.lightblueContainer, t),
      onLightblueContainer: Color.lerp(onLightblueContainer, other.onLightblueContainer, t),
      sourceLightgreen: Color.lerp(sourceLightgreen, other.sourceLightgreen, t),
      lightgreen: Color.lerp(lightgreen, other.lightgreen, t),
      onLightgreen: Color.lerp(onLightgreen, other.onLightgreen, t),
      lightgreenContainer: Color.lerp(lightgreenContainer, other.lightgreenContainer, t),
      onLightgreenContainer: Color.lerp(onLightgreenContainer, other.onLightgreenContainer, t),
      sourceLightyellow: Color.lerp(sourceLightyellow, other.sourceLightyellow, t),
      lightyellow: Color.lerp(lightyellow, other.lightyellow, t),
      onLightyellow: Color.lerp(onLightyellow, other.onLightyellow, t),
      lightyellowContainer: Color.lerp(lightyellowContainer, other.lightyellowContainer, t),
      onLightyellowContainer: Color.lerp(onLightyellowContainer, other.onLightyellowContainer, t),
    );
  }

  /// Returns an instance of [CustomColors] in which the following custom
  /// colors are harmonized with [dynamic]'s [ColorScheme.primary].
  ///   * [CustomColors.sourceLowgreen]
  ///   * [CustomColors.lowgreen]
  ///   * [CustomColors.onLowgreen]
  ///   * [CustomColors.lowgreenContainer]
  ///   * [CustomColors.onLowgreenContainer]
  ///   * [CustomColors.sourceSubprimary]
  ///   * [CustomColors.subprimary]
  ///   * [CustomColors.onSubprimary]
  ///   * [CustomColors.subprimaryContainer]
  ///   * [CustomColors.onSubprimaryContainer]
  ///   * [CustomColors.sourceSubtertiary]
  ///   * [CustomColors.subtertiary]
  ///   * [CustomColors.onSubtertiary]
  ///   * [CustomColors.subtertiaryContainer]
  ///   * [CustomColors.onSubtertiaryContainer]
  ///   * [CustomColors.sourceMediumprimary]
  ///   * [CustomColors.mediumprimary]
  ///   * [CustomColors.onMediumprimary]
  ///   * [CustomColors.mediumprimaryContainer]
  ///   * [CustomColors.onMediumprimaryContainer]
  ///   * [CustomColors.sourceMinusred]
  ///   * [CustomColors.minusred]
  ///   * [CustomColors.onMinusred]
  ///   * [CustomColors.minusredContainer]
  ///   * [CustomColors.onMinusredContainer]
  ///   * [CustomColors.sourceLightblue]
  ///   * [CustomColors.lightblue]
  ///   * [CustomColors.onLightblue]
  ///   * [CustomColors.lightblueContainer]
  ///   * [CustomColors.onLightblueContainer]
  ///   * [CustomColors.sourceLightgreen]
  ///   * [CustomColors.lightgreen]
  ///   * [CustomColors.onLightgreen]
  ///   * [CustomColors.lightgreenContainer]
  ///   * [CustomColors.onLightgreenContainer]
  ///   * [CustomColors.sourceLightyellow]
  ///   * [CustomColors.lightyellow]
  ///   * [CustomColors.onLightyellow]
  ///   * [CustomColors.lightyellowContainer]
  ///   * [CustomColors.onLightyellowContainer]
  ///
  /// See also:
  ///   * <https://m3.material.io/styles/color/the-color-system/custom-colors#harmonization>
  CustomColors harmonized(ColorScheme dynamic) {
    return copyWith(
      sourceLowgreen: sourceLowgreen!.harmonizeWith(dynamic.primary),
      lowgreen: lowgreen!.harmonizeWith(dynamic.primary),
      onLowgreen: onLowgreen!.harmonizeWith(dynamic.primary),
      lowgreenContainer: lowgreenContainer!.harmonizeWith(dynamic.primary),
      onLowgreenContainer: onLowgreenContainer!.harmonizeWith(dynamic.primary),
      sourceSubprimary: sourceSubprimary!.harmonizeWith(dynamic.primary),
      subprimary: subprimary!.harmonizeWith(dynamic.primary),
      onSubprimary: onSubprimary!.harmonizeWith(dynamic.primary),
      subprimaryContainer: subprimaryContainer!.harmonizeWith(dynamic.primary),
      onSubprimaryContainer: onSubprimaryContainer!.harmonizeWith(dynamic.primary),
      sourceSubtertiary: sourceSubtertiary!.harmonizeWith(dynamic.primary),
      subtertiary: subtertiary!.harmonizeWith(dynamic.primary),
      onSubtertiary: onSubtertiary!.harmonizeWith(dynamic.primary),
      subtertiaryContainer: subtertiaryContainer!.harmonizeWith(dynamic.primary),
      onSubtertiaryContainer: onSubtertiaryContainer!.harmonizeWith(dynamic.primary),
      sourceMediumprimary: sourceMediumprimary!.harmonizeWith(dynamic.primary),
      mediumprimary: mediumprimary!.harmonizeWith(dynamic.primary),
      onMediumprimary: onMediumprimary!.harmonizeWith(dynamic.primary),
      mediumprimaryContainer: mediumprimaryContainer!.harmonizeWith(dynamic.primary),
      onMediumprimaryContainer: onMediumprimaryContainer!.harmonizeWith(dynamic.primary),
      sourceMinusred: sourceMinusred!.harmonizeWith(dynamic.primary),
      minusred: minusred!.harmonizeWith(dynamic.primary),
      onMinusred: onMinusred!.harmonizeWith(dynamic.primary),
      minusredContainer: minusredContainer!.harmonizeWith(dynamic.primary),
      onMinusredContainer: onMinusredContainer!.harmonizeWith(dynamic.primary),
      sourceLightblue: sourceLightblue!.harmonizeWith(dynamic.primary),
      lightblue: lightblue!.harmonizeWith(dynamic.primary),
      onLightblue: onLightblue!.harmonizeWith(dynamic.primary),
      lightblueContainer: lightblueContainer!.harmonizeWith(dynamic.primary),
      onLightblueContainer: onLightblueContainer!.harmonizeWith(dynamic.primary),
      sourceLightgreen: sourceLightgreen!.harmonizeWith(dynamic.primary),
      lightgreen: lightgreen!.harmonizeWith(dynamic.primary),
      onLightgreen: onLightgreen!.harmonizeWith(dynamic.primary),
      lightgreenContainer: lightgreenContainer!.harmonizeWith(dynamic.primary),
      onLightgreenContainer: onLightgreenContainer!.harmonizeWith(dynamic.primary),
      sourceLightyellow: sourceLightyellow!.harmonizeWith(dynamic.primary),
      lightyellow: lightyellow!.harmonizeWith(dynamic.primary),
      onLightyellow: onLightyellow!.harmonizeWith(dynamic.primary),
      lightyellowContainer: lightyellowContainer!.harmonizeWith(dynamic.primary),
      onLightyellowContainer: onLightyellowContainer!.harmonizeWith(dynamic.primary),
    );
  }
}