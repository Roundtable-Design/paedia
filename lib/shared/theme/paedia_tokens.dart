import 'package:flutter/material.dart';
import 'paedia_colors.dart';

/// Spacing, typography, and layout tokens for Paedia.
@immutable
class PaediaTokens extends ThemeExtension<PaediaTokens> {
  const PaediaTokens({
    required this.spacingXs,
    required this.spacingSm,
    required this.spacingMd,
    required this.spacingLg,
    required this.spacingXl,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.maxContentWidth,
    required this.fastingDay,
    required this.sabbathDay,
    required this.programmeComplete,
    required this.offline,
  });

  final double spacingXs;
  final double spacingSm;
  final double spacingMd;
  final double spacingLg;
  final double spacingXl;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double maxContentWidth;
  final Color fastingDay;
  final Color sabbathDay;
  final Color programmeComplete;
  final Color offline;

  static const PaediaTokens dark = PaediaTokens(
    spacingXs: 4,
    spacingSm: 8,
    spacingMd: 16,
    spacingLg: 24,
    spacingXl: 32,
    radiusSm: 8,
    radiusMd: 12,
    radiusLg: 16,
    maxContentWidth: 680,
    fastingDay: PaediaColors.fastingDay,
    sabbathDay: PaediaColors.sabbathDay,
    programmeComplete: PaediaColors.programmeComplete,
    offline: PaediaColors.offline,
  );

  static const PaediaTokens light = dark;

  @override
  PaediaTokens copyWith({
    double? spacingXs,
    double? spacingSm,
    double? spacingMd,
    double? spacingLg,
    double? spacingXl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? maxContentWidth,
    Color? fastingDay,
    Color? sabbathDay,
    Color? programmeComplete,
    Color? offline,
  }) {
    return PaediaTokens(
      spacingXs: spacingXs ?? this.spacingXs,
      spacingSm: spacingSm ?? this.spacingSm,
      spacingMd: spacingMd ?? this.spacingMd,
      spacingLg: spacingLg ?? this.spacingLg,
      spacingXl: spacingXl ?? this.spacingXl,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
      fastingDay: fastingDay ?? this.fastingDay,
      sabbathDay: sabbathDay ?? this.sabbathDay,
      programmeComplete: programmeComplete ?? this.programmeComplete,
      offline: offline ?? this.offline,
    );
  }

  @override
  PaediaTokens lerp(ThemeExtension<PaediaTokens>? other, double t) {
    if (other is! PaediaTokens) return this;
    return PaediaTokens(
      spacingXs: spacingXs,
      spacingSm: spacingSm,
      spacingMd: spacingMd,
      spacingLg: spacingLg,
      spacingXl: spacingXl,
      radiusSm: radiusSm,
      radiusMd: radiusMd,
      radiusLg: radiusLg,
      maxContentWidth: maxContentWidth,
      fastingDay: Color.lerp(fastingDay, other.fastingDay, t)!,
      sabbathDay: Color.lerp(sabbathDay, other.sabbathDay, t)!,
      programmeComplete:
          Color.lerp(programmeComplete, other.programmeComplete, t)!,
      offline: Color.lerp(offline, other.offline, t)!,
    );
  }
}

extension PaediaTokensContext on BuildContext {
  PaediaTokens get paediaTokens =>
      Theme.of(this).extension<PaediaTokens>() ?? PaediaTokens.dark;
}
