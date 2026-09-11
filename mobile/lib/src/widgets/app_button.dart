import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Visual weight of an [AppButton], matching iOS button styles.
enum AppButtonVariant {
  /// Solid accent fill with contrasting text.
  filled,

  /// Translucent accent-tinted background with accent text.
  tinted,

  /// No background; accent text only.
  plain,
}

/// An iOS-style button with a consistent corner radius and optional icon.
///
/// Wraps [CupertinoButton] so callers get the three HIG button weights without
/// re-stating padding, color, and typography at every call site.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final Color? tint;
  final bool expanded;
  final bool small;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.tint,
    this.expanded = false,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = (tint ?? AppColors.accent).rc(context);
    final radius = BorderRadius.circular(small ? 10 : 14);
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 20, vertical: 14);
    final textStyle = (small ? AppTheme.subheadline : AppTheme.headline).copyWith(
      fontWeight: FontWeight.w600,
    );

    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: small ? 16 : 18),
          const SizedBox(width: 6),
        ],
        Text(label, style: textStyle),
      ],
    );

    final Widget button = switch (variant) {
      AppButtonVariant.filled => CupertinoButton.filled(
          onPressed: onPressed,
          padding: padding,
          borderRadius: radius,
          color: accent,
          foregroundColor: CupertinoColors.white,
          child: child,
        ),
      AppButtonVariant.tinted => CupertinoButton(
          onPressed: onPressed,
          padding: padding,
          borderRadius: radius,
          color: accent.withValues(alpha: 0.15),
          foregroundColor: accent,
          child: child,
        ),
      AppButtonVariant.plain => CupertinoButton(
          onPressed: onPressed,
          padding: padding,
          borderRadius: radius,
          child: child,
        ),
    };

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
