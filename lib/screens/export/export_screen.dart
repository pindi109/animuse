
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animuse/core/theme/app_colors.dart';
import 'package:animuse/models/export_model.dart';
import 'package:animuse/providers/export_provider.dart';
import 'package:animuse/widgets/primary_button.dart';
import 'package:animuse/widgets/status_badge.dart';
import 'package:animuse/models/scene.dart';

class ExportScreen extends ConsumerStatefulWidget {
  final String exportId;

  const ExportScreen({super.key, required this.exportId});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(exportProvider(widget.exportId).notifier)
          .loadExport(widget.exportId);
    });
  }

  Future<void> _handleDownload(ExportModel export) async {
    try {
      await ref
          .read(exportProvider(widget.exportId).notifier)
          .downloadPackage(widget.exportId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Download started'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.toString()}'),
            backgroundColor: AppColors.statusFailed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exportAsync = ref.watch(exportProvider(widget.exportId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: exportAsync.when(
        loading: () => const _FullScreenLoader(),
        error: (error, _) => _FullScreenError(
          message: error.toString(),
          onBack: () => context.go('/'),
        ),
        data: (export) {
          if (export == null) {
            return _FullScreenError(
              message: 'Export not found.',
              onBack: () => context.go('/'),
            );
          }
          return Column(
            children: [
              _ExportTopBar(
                export: export,
                onBack: () => context.go('/workspace/${export.projectId}'),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _SceneStatusList(export: export),
                    ),
                    Container(width: 1, color: AppColors.border),
                    Expanded(
                      flex: 2,
                      child: _ExportSidebar(
                        export: export,
                        onDownload: () => _handleDownload(export),
                        onBack: () =>
                            context.go('/workspace/${export.projectId}'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExportTopBar extends StatelessWidget {
  final ExportModel export;
  final VoidCallback onBack;

  const _ExportTopBar({required this.export, required this.onBack});

  @override
  Widget build(BuildContext context) {
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
          Container(width: 1, height: 24, color: AppColors.border),
          const SizedBox(width: 16),
          const Text(
            'Export',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 10),
          _VersionBadge(version: export.version),
          const Spacer(),
          TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 15),
            label: const Text('Back to Workspace'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionBadge extends StatelessWidget {
  final int version;

  const _VersionBadge({required this.version});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.statusLocked,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'v$version',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A3FA0),
        ),
      ),
    );
  }
}

class _SceneStatusList extends StatelessWidget {
  final ExportModel export;

  const _SceneStatusList({required this.export});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Scene Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Text(
                  '${export.scenes.length} scenes',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: export.scenes.isEmpty
                ? const Center(
                    child: Text(
                      'No scenes in this export.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    itemCount: export.scenes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final exportScene = export.scenes[index];
                      return _ExportSceneRow(exportScene: exportScene);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ExportSceneRow extends StatelessWidget {
  final ExportSceneItem exportScene;

  const _ExportSceneRow({required this.exportScene});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${exportScene.sceneIndex + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              exportScene.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          _StatusIndicator(
            label: 'Animation',
            status: exportScene.animationStatus,
          ),
          const SizedBox(width: 8),
          _StatusIndicator(
            label: 'Audio',
            status: exportScene.narrationAudioStatus,
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final String status;

  const _StatusIndicator({required this.label, required this.status});

  Color get _bgColor {
    switch (status.toLowerCase()) {
      case 'ready':
      case 'completed':
        return AppColors.statusApproved;
      case 'generating':
      case 'processing':
        return AppColors.statusGenerating;
      case 'failed':
        return AppColors.statusFailed;
      case 'pending':
      default:
        return AppColors.statusPending;
    }
  }

  Color get _textColor {
    switch (status.toLowerCase()) {
      case 'ready':
      case 'completed':
        return const Color(0xFF1B6B44);
      case 'generating':
      case 'processing':
        return const Color(0xFF8A5A0A);
      case 'failed':
        return const Color(0xFFB00020);
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _textColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportSidebar extends StatelessWidget {
  final ExportModel export;
  final VoidCallback onDownload;
  final VoidCallback onBack;

  const _ExportSidebar({
    required this.export,
    required this.onDownload,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final completedScenes =
        export.scenes.where((s) => s.animationStatus.toLowerCase() == 'ready' || s.animationStatus.toLowerCase() == 'completed').length;
    final totalScenes = export.scenes.length;
    final allReady = completedScenes == totalScenes && totalScenes > 0;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Package',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _ExportInfoCard(export: export),
          const SizedBox(height: 20),
          _ProgressCard(
            completed: completedScenes,
            total: totalScenes,
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: allReady ? 'Download Package' : 'Download (Partial)',
            onPressed: onDownload,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, size: 16),
            label: const Text(
              'Back to Workspace',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 24),
          if (export.status == ExportStatus.failed) ...[
            _ExportErrorCard(),
          ],
        ],
      ),
    );
  }
}

class _ExportInfoCard extends StatelessWidget {
  final ExportModel export;

  const _ExportInfoCard({required this.export});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'Export ID', value: export.id.substring(0, 8) + '…'),
          const SizedBox(height: 10),
          _InfoRow(label: 'Version', value: 'v${export.version}'),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Status',
            value: export.status.name[0].toUpperCase() +
                export.status.name.substring(1),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Scenes',
            value: '${export.scenes.length} total',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressCard({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Animation Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$completed / $total',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.accent),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% complete',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExportErrorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.statusFailed,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFB00020).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFB00020), size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Export failed. Please return to workspace and try again.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFB00020),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullScreenLoader extends StatelessWidget {
  const _FullScreenLoader();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
          SizedBox(height: 20),
          Text(
            'Loading export…',
            style: TextStyle(
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
  final VoidCallback onBack;

  const _FullScreenError({required this.message, required this.onBack});

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
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFB00020),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Export not available',
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
              label: 'Go Back',
              onPressed: onBack,
            ),
          ],
        ),
      ),
    );
  }
}