
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animuse/core/theme/app_colors.dart';
import 'package:animuse/models/scene.dart';
import 'package:animuse/widgets/scene_card.dart';

class StoryboardGrid extends ConsumerWidget {
  final String projectId;
  final List<Scene> scenes;
  final String? selectedSceneId;
  final ValueChanged<String> onSceneSelected;

  const StoryboardGrid({
    super.key,
    required this.projectId,
    required this.scenes,
    required this.selectedSceneId,
    required this.onSceneSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CRITICAL: Always sort by sceneIndex ascending — never use server return order
    final sortedScenes = [...scenes]
      ..sort((a, b) => a.sceneIndex.compareTo(b.sceneIndex));

    if (sortedScenes.isEmpty) {
      return _EmptyGrid();
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GridHeader(sceneCount: sortedScenes.length),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: sortedScenes.length,
              itemBuilder: (context, index) {
                final scene = sortedScenes[index];
                return SceneCard(
                  scene: scene,
                  isSelected: scene.id == selectedSceneId,
                  onTap: () => onSceneSelected(scene.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GridHeader extends StatelessWidget {
  final int sceneCount;

  const _GridHeader({required this.sceneCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Storyboard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Text(
            '$sceneCount scenes',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: const Icon(
              Icons.view_module_outlined,
              size: 36,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No scenes yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Scenes will appear here as they are generated.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}