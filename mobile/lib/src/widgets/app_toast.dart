import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Shows a transient, non-blocking message near the bottom of the screen.
///
/// Mirrors the feedback role of a snackbar without pulling a Material
/// dependency into the Cupertino app.
void showAppToast(BuildContext context, String message, {bool isError = false}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _AppToast(
      message: message,
      isError: isError,
      onDismissed: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _AppToast extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismissed;

  const _AppToast({
    required this.message,
    required this.isError,
    required this.onDismissed,
  });

  @override
  State<_AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<_AppToast> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    _timer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      setState(() => _visible = false);
      Timer(const Duration(milliseconds: 220), widget.onDismissed);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom + 16;
    final background = widget.isError
        ? AppColors.high.rc(context)
        : AppColors.label.rc(context);
    final foreground =
        widget.isError ? CupertinoColors.white : AppColors.background.rc(context);

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottom,
      child: IgnorePointer(
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          offset: _visible ? Offset.zero : const Offset(0, 0.4),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _visible ? 1 : 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.black.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: AppTheme.subheadline.copyWith(color: foreground),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
