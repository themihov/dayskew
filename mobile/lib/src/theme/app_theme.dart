import 'package:flutter/cupertino.dart';

/// Typography and theme for DaySkew, following Apple's Human Interface
/// Guidelines: a clear type ramp, generous line height, and an accent-driven
/// Cupertino theme that adapts to the system appearance.
abstract final class AppTheme {
  /// App-wide Cupertino theme. Brightness is intentionally left unset so it
  /// follows the device's light/dark setting; the semantic color tokens
  /// resolve accordingly.
  static const CupertinoThemeData cupertino = CupertinoThemeData(
    primaryColor: CupertinoColors.systemBlue,
    applyThemeToAll: true,
  );

  // --- Type ramp (sizes/weights per HIG), colors inherit from the resolved
  // default text style so light/dark is handled automatically. ---

  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.37,
    height: 1.15,
  );

  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.36,
    height: 1.15,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.26,
    height: 1.2,
  );

  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.45,
    height: 1.2,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.41,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.41,
    height: 1.35,
  );

  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
    height: 1.35,
  );

  static const TextStyle subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.24,
    height: 1.33,
  );

  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.08,
    height: 1.38,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.33,
  );

  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.07,
    height: 1.36,
  );

  /// Section label above grouped content. Sentence case, secondary color,
  /// weighted like an iOS grouped-list header.
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.08,
    height: 1.38,
  );

  // --- Metric styles: tabular figures keep time columns from jittering. ---

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  static const TextStyle metricLarge = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.2,
    height: 1.05,
    fontFeatures: _tabular,
  );

  static const TextStyle metric = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.2,
    fontFeatures: _tabular,
  );

  static const TextStyle metricSmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.08,
    height: 1.2,
    fontFeatures: _tabular,
  );
}
