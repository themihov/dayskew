import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/time_format.dart';
import 'app_button.dart';
import 'app_surface.dart';

/// The reflow trigger: shows the applied wake-up time and lets the user either
/// stamp "now" with one tap or pick a different time. This is the primary
/// action of the app, so it anchors the top of the screen.
class ReflowHero extends StatelessWidget {
  final int wakeTime;
  final bool isReflowing;
  final VoidCallback onJustWokeUp;
  final VoidCallback onTimeTap;

  const ReflowHero({
    super.key,
    required this.wakeTime,
    required this.isReflowing,
    required this.onJustWokeUp,
    required this.onTimeTap,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Late night';
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: AppTheme.subheadline.copyWith(
                        color: AppColors.secondaryLabel.rc(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: isReflowing ? null : onTimeTap,
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            TimeFormat.hhmmAmPm(wakeTime),
                            style: AppTheme.metricLarge,
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            CupertinoIcons.pencil,
                            size: 16,
                            color: AppColors.accent.rc(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Actual wake-up time',
                      style: AppTheme.footnote.copyWith(
                        color: AppColors.tertiaryLabel.rc(context),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.medium.rc(context).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.sun_max_fill,
                  size: 26,
                  color: AppColors.medium.rc(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppButton(
            label: isReflowing ? 'Reflowing…' : 'Just Woke Up',
            icon: isReflowing ? null : CupertinoIcons.bolt_fill,
            onPressed: isReflowing
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    onJustWokeUp();
                  },
            expanded: true,
          ),
          const SizedBox(height: 4),
          Center(
            child: AppButton(
              label: 'Or set a different time',
              variant: AppButtonVariant.plain,
              small: true,
              onPressed: isReflowing ? null : onTimeTap,
            ),
          ),
        ],
      ),
    );
  }
}
