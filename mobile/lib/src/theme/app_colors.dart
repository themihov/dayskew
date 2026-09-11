import 'package:flutter/cupertino.dart';

/// Semantic color system built on Apple's dynamic system colors.
///
/// Every token is a [CupertinoDynamicColor] so it automatically adapts to
/// light/dark appearance and high-contrast accessibility settings. Resolve a
/// token against a [BuildContext] with [resolve] (or the `rc` extension)
/// before painting it on a custom surface.
abstract final class AppColors {
  // Surfaces.
  static const CupertinoDynamicColor background = CupertinoColors.systemBackground;
  static const CupertinoDynamicColor groupedBackground =
      CupertinoColors.systemGroupedBackground;
  static const CupertinoDynamicColor secondaryBackground =
      CupertinoColors.secondarySystemBackground;
  static const CupertinoDynamicColor groupedSecondaryBackground =
      CupertinoColors.secondarySystemGroupedBackground;
  static const CupertinoDynamicColor fill = CupertinoColors.systemFill;

  // Content.
  static const CupertinoDynamicColor label = CupertinoColors.label;
  static const CupertinoDynamicColor secondaryLabel = CupertinoColors.secondaryLabel;
  static const CupertinoDynamicColor tertiaryLabel = CupertinoColors.tertiaryLabel;
  static const CupertinoDynamicColor separator = CupertinoColors.separator;

  // Accents.
  static const CupertinoDynamicColor accent = CupertinoColors.systemBlue;

  static const CupertinoDynamicColor high = CupertinoColors.systemRed;
  static const CupertinoDynamicColor medium = CupertinoColors.systemOrange;
  static const CupertinoDynamicColor low = CupertinoColors.systemGreen;
  static const CupertinoDynamicColor conflict = CupertinoColors.systemYellow;
  static const CupertinoDynamicColor locked = CupertinoColors.systemIndigo;

  /// Resolves a dynamic token for the current appearance.
  static Color resolve(BuildContext context, Color color) =>
      CupertinoDynamicColor.resolve(color, context);

  /// Returns the tier color for a task priority (1 = high, 2 = medium, 3 = low).
  static CupertinoDynamicColor forPriority(int priority) {
    switch (priority) {
      case 1:
        return high;
      case 2:
        return medium;
      default:
        return low;
    }
  }

  /// Title-case priority name used in badges and rows.
  static String priorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      default:
        return 'Low';
    }
  }
}

/// Convenience: resolve any [Color] against a context, adapting dynamic
/// system colors to the current light/dark appearance.
extension ResolvedColor on Color {
  // ignore: non_constant_identifier_names
  Color rc(BuildContext context) => CupertinoDynamicColor.resolve(this, context);
}
