import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ToastType { success, error, info }

class ToastHelper {
  const ToastHelper._();

  static OverlayEntry? _currentEntry;

  static void show({
    required String title,
    required String message,
    ToastType type = ToastType.info,
  }) {
    final context = Get.context;
    if (context == null) {
      return;
    }

    final overlay =
        Get.key.currentState?.overlay ??
        Navigator.maybeOf(context, rootNavigator: true)?.overlay;
    if (overlay == null) {
      return;
    }

    _dismissCurrent();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _TopToast(
        title: title,
        message: message,
        type: type,
        onDismiss: () => _dismiss(entry),
        onDisposed: () {
          if (identical(_currentEntry, entry)) {
            _currentEntry = null;
          }
        },
      ),
    );
    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void _dismissCurrent() {
    final entry = _currentEntry;
    if (entry != null) {
      _dismiss(entry);
    }
  }

  static void _dismiss(OverlayEntry entry) {
    if (identical(_currentEntry, entry)) {
      _currentEntry = null;
    }
    if (entry.mounted) {
      entry.remove();
      entry.dispose();
    }
  }

  static void success(String title, String message) {
    show(title: title, message: message, type: ToastType.success);
  }

  static void error(String title, String message) {
    show(title: title, message: message, type: ToastType.error);
  }

  static void info(String title, String message) {
    show(title: title, message: message);
  }
}

class _TopToast extends StatefulWidget {
  const _TopToast({
    required this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
    required this.onDisposed,
  });

  final String title;
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;
  final VoidCallback onDisposed;

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast> {
  late final Timer _dismissTimer;

  @override
  void initState() {
    super.initState();
    _dismissTimer = Timer(const Duration(milliseconds: 2200), widget.onDismiss);
  }

  @override
  void dispose() {
    _dismissTimer.cancel();
    widget.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isError = widget.type == ToastType.error;
    final isSuccess = widget.type == ToastType.success;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: IgnorePointer(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0, end: 1),
            builder: (context, progress, child) {
              return Opacity(
                opacity: progress,
                child: Transform.translate(
                  offset: Offset(0, -12 * (1 - progress)),
                  child: child,
                ),
              );
            },
            child: Material(
              color: isError
                  ? const Color(0xFFB3261E)
                  : isSuccess
                  ? const Color(0xFF253019)
                  : const Color(0xFF1E1E1E),
              elevation: 8,
              shadowColor: Colors.black54,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
                child: Row(
                  children: [
                    Icon(
                      isError
                          ? Icons.error_outline_rounded
                          : isSuccess
                          ? Icons.check_circle_outline_rounded
                          : Icons.info_outline_rounded,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
