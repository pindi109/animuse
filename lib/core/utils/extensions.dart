
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ---------------------------------------------------------------------------
// BuildContext extensions
// ---------------------------------------------------------------------------

extension BuildContextX on BuildContext {
  /// Access the current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Access the current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Access the current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Screen size shorthand.
  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Responsive breakpoints.
  bool get isCompact => screenWidth < 600;
  bool get isMedium => screenWidth >= 600 && screenWidth < 1200;
  bool get isExpanded => screenWidth >= 1200;

  /// Show a simple snackbar.
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  /// Show an error snackbar styled with the error colour.
  void showErrorSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: const Color(0xFFD32F2F),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// String extensions
// ---------------------------------------------------------------------------

extension StringX on String {
  /// Capitalise the first letter.
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Truncate with ellipsis if longer than [maxLength].
  String truncate(int maxLength) =>
      length > maxLength ? '${substring(0, maxLength)}…' : this;

  /// Convert a snake_case or camelCase string to Title Case words.
  String get toTitleCase => replaceAll(RegExp(r'[_-]'), ' ')
      .split(' ')
      .map((w) => w.capitalised)
      .join(' ');

  /// Returns true if the string is a valid HTTP/HTTPS URL.
  bool get isUrl {
    try {
      final uri = Uri.parse(this);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  /// Returns true if not empty after trimming.
  bool get isNotBlank => trim().isNotEmpty;

  /// Returns true if empty after trimming.
  bool get isBlank => trim().isEmpty;
}

// ---------------------------------------------------------------------------
// DateTime extensions
// ---------------------------------------------------------------------------

extension DateTimeX on DateTime {
  /// Formats as "Jan 5, 2025".
  String get formatted => DateFormat('MMM d, y').format(this);

  /// Formats as "Jan 5, 2025 at 3:42 PM".
  String get formattedWithTime => DateFormat('MMM d, y').add_jm().format(this);

  /// Returns a human-readable relative time (e.g. "2 minutes ago").
  String get timeAgo {
    final diff =