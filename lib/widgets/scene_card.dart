
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:animuse/core/theme/app_colors.dart';
import 'package:animuse/core/theme/app_text_styles.dart';
import 'package:animuse/models/scene.dart';
import 'package:animuse/widgets/status_badge.dart';

class SceneCard extends StatelessWidget {
  final Scene scene;
  final bool isSelected;
  final VoidCallback onTap;

  const SceneCard({
    super.key,
    required this.scene,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildThumbnail(),
                    // Scene index badge — top left
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _SceneIndexBadge(index: scene.sceneIndex + 1),
                    ),
                    // Lock overlay
                    if (scene.isLocked) _buildLockOverlay(),
                    // Approved checkmark
                    if (scene.status == SceneStatus.approved)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _buildApprovedBadge(),
                      ),
                  ],
                ),
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scene.title,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  StatusBadge(status: scene.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (scene.imageUrl != null && scene.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: scene.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => const _GreyPlaceholder(),
        errorWidget: (context, url, error) => const _GreyPlaceholder(),
      );
    }
    return const _GreyPlaceholder();
  }

  Widget _buildLockOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.35),
      child: const Center(
        child: Icon(
          Icons.lock,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildApprovedBadge() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.statusApproved,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: const Icon(
        Icons.check,
        color: Color(0xFF2E7D5E),
        size: 14,
      ),
    );
  }
}

class _GreyPlaceholder extends StatelessWidget {
  const _GreyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.border,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textSecondary,
          size: 32,
        ),
      ),
    );
  }
}

class _SceneIndexBadge extends StatelessWidget {
  final int index;

  const _SceneIndexBadge({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$index',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}