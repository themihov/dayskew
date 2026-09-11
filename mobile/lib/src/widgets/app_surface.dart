import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// A grouped content card: rounded rect, adaptive surface, hairline border,
/// and a soft shadow that gives the timeline depth without heavy chrome.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;
  final bool bordered;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
    this.onTap,
    this.bordered = true,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: (color ?? AppColors.groupedSecondaryBackground).rc(context),
      borderRadius: BorderRadius.circular(18),
      border: bordered
          ? Border.all(color: AppColors.separator.rc(context).withValues(alpha: 0.5))
          : null,
      boxShadow: [
        BoxShadow(
          color: CupertinoColors.black.withValues(alpha: 0.06),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );

    final content = Container(
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: content);
  }
}

/// Sentence-case section header used above grouped content, matching iOS
/// grouped-list conventions.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            title,
            style: AppTheme.sectionHeader.copyWith(
              color: AppColors.secondaryLabel.rc(context),
            ),
          ),
          if (trailing != null)
            Flexible(
              child: Text(
                trailing!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: AppTheme.caption.copyWith(
                  color: AppColors.tertiaryLabel.rc(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
