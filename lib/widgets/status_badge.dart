
import 'package:flutter/material.dart';

import 'package:animuse/core/theme/app_colors.dart';
import 'package:animuse/models/scene.dart';

class StatusBadge extends StatelessWidget {
  final SceneStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _label,
            style: TextStyle(
              color: _textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  String get _label {
    switch (status) {
      case SceneStatus.pending:
        return 'pending';
      case SceneStatus.generating:
        return 'generating';
      case SceneStatus.ready:
        return 'ready';
      case SceneStatus.approved:
        return 'approved';
      case SceneStatus.locked:
        return 'locked';
      case SceneStatus.failed:
        return 'failed';
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case SceneStatus.pending:
        return AppColors.statusPending;
      case SceneStatus.generating:
        return AppColors.statusGenerating;
      case SceneStatus.ready:
        return AppColors.statusReady;
      case SceneStatus.approved:
        return AppColors.statusApproved;
      case SceneStatus.locked:
        return AppColors.statusLocked;
      case SceneStatus.failed:
        return AppColors.statusFailed;
    }
  }

  Color get _textColor {
    switch (status) {
      case SceneStatus.pending:
        return const Color(0xFF555555);
      case SceneStatus.generating:
        return const Color(0xFF7A5800);
      case SceneStatus.ready:
        return const Color(0xFF3A6200);
      case SceneStatus.approved:
        return const Color(0xFF2E7D5E);
      case SceneStatus.locked:
        return const Color(0xFF4A3FA0);
      case SceneStatus.failed:
        return const Color(0xFFB02020);
    }
  }

  Color get _dotColor => _textColor;
}