
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animuse/core/theme/app_colors.dart';
import 'package:animuse/core/theme/app_text_styles.dart';
import 'package:animuse/models/project.dart';
import 'package:animuse/models/scene.dart';
import 'package:animuse/providers/project_provider.dart';
import 'package:animuse/providers/scene_provider.dart';
import 'package:animuse/providers/polling_provider.dart';
import 'package:animuse/widgets/status_badge.dart';
import 'package:animuse/widgets/primary_button.dart';
import 'package:animuse/screens/workspace/storyboard_grid.dart';
import 'package:animuse/screens/workspace/scene_inspector.dart';

class WorkspaceScreen extends ConsumerStatefulWidget {
  final String projectId;

  const WorkspaceScreen({super.key, required this.projectId});

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  String? _selectedSceneId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projectProvider(widget.projectId).notifier).loadProject(widget.projectId);
      ref.read(sceneProvider(widget.projectId).notifier).loadScenes(widget.projectId);
      ref.read(pollingProvider(widget.projectId).notifier).startPolling(widget.projectId);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onSceneSelected(String sceneId) {
    setState(() => _selectedSceneId = sceneId);
  }

  Future<void> _handleRegenerateAll() async {
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Regenerate All Scenes',
      message:
          'This will regenerate all unlocked scenes. Locked scenes will not be affected. Continue?',
      confirmLabel: 'Regenerate',
    );
    if (!confirmed) return;

    try {
      await ref
          .read(projectProvider(widget.projectId).notifier)
          .regenerateAll(widget.projectId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Regeneration started for all unlocked scenes'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to regenerate: ${e.toString()}'),
            backgroundColor: AppColors.statusFailed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleApproveAll() async {
    final confirmed = await _showConfirmDialog(
      context,
      title: 'Approve All Scenes',
      message:
          'This will approve all ready scenes. Continue?',
      confirmLabel: 'Approve All',
    );
    if (!confirmed) return;

    try {
      await ref
          .read(sceneProvider(widget.projectId).notifier)
          .approveAll();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All ready scenes approved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve all: ${e.toString()}'),
            backgroundColor: AppColors.statusFailed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleExport() async {
    try {
      final exportId = await ref
          .read(projectProvider(widget.projectId).notifier)
          .exportProject(widget.projectId);

      if (mounted) {
        context.go('/export/$exportId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: AppColors.statusFailed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectProvider(widget.projectId));
    final scenesAsync = ref.watch(sceneProvider(widget.projectId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: projectAsync.when(
        loading: () => const _FullScreenLoader(message: 'Loading project…'),
        error: (error, _) => _FullScreenError(
          message: error.toString(),
          onStartOver: () => context.go('/'),
        ),
        data: (project) {
          if (project == null) {
            return _FullScreenError(
              message: 'Project not found.',
              onStartOver: () => context.go('/'),
            );
          }
          return Column(
            children: [
              _TopBar(
                project: project,
                onRegenerateAll: _handleRegenerateAll,
                onApproveAll: _handleApproveAll,
                onExport: _handleExport,
              ),
              Expanded(
                child: scenesAsync.when(
                  loading: () =>
                      const _FullScreenLoader(message: 'Loading scenes…'),
                  error: (error, _) => Center(
                    child: Text(
                      'Error loading scenes: ${error.toString()}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  data: (scenes) {
                    if (scenes.isEmpty &&
                        (project.status == ProjectStatus.planning ||
                            project.status == ProjectStatus.storyboarding)) {
                      return const _GeneratingPlaceholder();
                    }

                    final selectedScene = _selectedSceneId != null
                        ? scenes
                            .where((s) => s.id == _selectedSceneId)
                            .firstOrNull
                        : (scenes.isNotEmpty ? scenes.first : null);

                    if (selectedScene == null && scenes.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() => _selectedSceneId = scenes.first.id);
                      });
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: StoryboardGrid(
                            projectId: widget.projectId,
                            scenes: scenes,
                            selectedSceneId: selectedScene?.id,
                            onSceneSelected: _onSceneSelected,
                          ),
                        ),
                        Container(
                          width: 1,
                          color: AppColors.border,
                        ),
                        Expanded(
                          flex: 4,
                          child: SceneInspector(
                            projectId: widget.projectId,
                            scene: selectedScene,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final Project project;
  final VoidCallback onRegenerateAll;
  final VoidCallback onApproveAll;
  final VoidCallback onExport;

  const _TopBar({
    required this.project,
    required this.onRegenerateAll,
    required this.onApproveAll,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final canExport = project.status == ProjectStatus.review ||
        project.status == ProjectStatus.completed;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/'),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.movie_filter_rounded,
                      color: Colors.white, size: 17),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Animuse',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 24,
            color: AppColors.border,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              project.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          _ProjectStatusChip(status: project.status),
          const SizedBox(width: 16),
          _TopBarButton(
            label: 'Regenerate All',
            icon: Icons.refresh_rounded,
            onPressed: onRegenerateAll,
          ),
          const SizedBox(width: 8),
          _TopBarButton(
            label: 'Approve All',
            icon: Icons.check_circle_outline_rounded,
            onPressed: onApproveAll,
          ),
          const SizedBox(width: 8),
          _ExportButton(
            onPressed: canExport ? onExport : null,
          ),
        ],
      ),
    );
  }
}

class _ProjectStatusChip extends StatelessWidget {
  final ProjectStatus status;

  const _ProjectStatusChip({required this.status});

  Color get _backgroundColor {
    switch (status) {
      case ProjectStatus.draft:
        return AppColors.statusPending;
      case ProjectStatus.planning:
      case ProjectStatus.storyboarding:
        return AppColors.statusGenerating;
      case ProjectStatus.review:
        return AppColors.statusReady;
      case ProjectStatus.exporting:
        return AppColors.statusLocked;
      case ProjectStatus.completed:
        return AppColors.statusApproved;
      case ProjectStatus.failed:
        return AppColors.statusFailed;
    }
  }

  Color get _textColor {
    switch (status) {
      case ProjectStatus.failed:
        return const Color(0xFFB00020);
      case ProjectStatus.completed:
        return const Color(0xFF1B6B44);
      case ProjectStatus.review:
        return const Color(0xFF2D6A1F);
      case ProjectStatus.planning:
      case ProjectStatus.storyboarding:
        return const Color(0xFF8A5A0A);
      case ProjectStatus.exporting:
        return const Color(0xFF4A3FA0);
      default:
        return AppColors.textSecondary;
    }
  }

  String get _label => status.name[0].toUpperCase() + status.name.substring(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == ProjectStatus.planning ||
              status == ProjectStatus.storyboarding) ...[
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation(_textColor),
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            _label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  const _TopBarButton({
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _ExportButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            onPressed != null ? AppColors.accent : AppColors.statusPending,
        foregroundColor:
            onPressed != null ? Colors.white : AppColors.textSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.file_download_outlined, size: 15),
      label: const Text(
        'Export',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _FullScreenLoader extends StatelessWidget {
  final String message;

  const _FullScreenLoader({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenError extends StatelessWidget {
  final String message;
  final VoidCallback onStartOver;

  const _FullScreenError({
    required this.message,
    required this.onStartOver,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.statusFailed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFB00020), size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Start Over',
              onPressed: onStartOver,
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratingPlaceholder extends StatelessWidget {
  const _GeneratingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
          const SizedBox(height: 24),
          const Text(
            'Generating your storyboard…',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a minute. Scenes will appear as they\'re ready.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}