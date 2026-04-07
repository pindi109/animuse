
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animuse/core/theme/app_colors.dart';
import 'package:animuse/models/scene.dart';
import 'package:animuse/providers/scene_provider.dart';
import 'package:animuse/widgets/status_badge.dart';
import 'package:animuse/widgets/primary_button.dart';

class SceneInspector extends ConsumerStatefulWidget {
  final String projectId;
  final Scene? scene;

  const SceneInspector({
    super.key,
    required this.projectId,
    required this.scene,
  });

  @override
  ConsumerState<SceneInspector> createState() => _SceneInspectorState();
}

class _SceneInspectorState extends ConsumerState<SceneInspector> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _narrationController;
  late TextEditingController _imagePromptController;
  late TextEditingController _animationPromptController;

  String? _lastSceneId;

  @override
  void initState() {
    super.initState();
    _narrationController = TextEditingController();
    _imagePromptController = TextEditingController();
    _animationPromptController = TextEditingController();
    _populateFromScene(widget.scene);
  }

  @override
  void didUpdateWidget(SceneInspector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scene?.id != _lastSceneId) {
      _isEditing = false;
      _populateFromScene(widget.scene);
    }
  }

  void _populateFromScene(Scene? scene) {
    _lastSceneId = scene?.id;
    _narrationController.text = scene?.narrationText ?? '';
    _imagePromptController.text = scene?.imagePrompt ?? '';
    _animationPromptController.text = scene?.animationPrompt ?? '';
  }

  @override
  void dispose() {
    _narrationController.dispose();
    _imagePromptController.dispose();
    _animationPromptController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final scene = widget.scene;
    if (scene == null) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(sceneProvider(widget.projectId).notifier).updateScene(
        scene.id,
        {
          'narration_text': _narrationController.text.trim(),
          'image_prompt': _imagePromptController.text.trim(),
          'animation_prompt': _animationPromptController.text.trim(),
        },
      );
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scene saved successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: AppColors.statusFailed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleRegenerateImage() async {
    final scene = widget.scene;
    if (scene == null) return;

    try {
      await ref
          .read(sceneProvider(widget.projectId).notifier)
          .regenerateImage(scene.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image regeneration started'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to regenerate image: ${e.toString()}'),
            backgroundColor: AppColors.statusFailed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleRegenerateText() async {
    final scene = widget.scene;
    if (scene == null) return;

    try {
      await ref
          .read(sceneProvider(widget.projectId).notifier)
          .regenerateText(scene.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Text regeneration started'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to regenerate text: ${e.toString()}'),
            backgroundColor: AppColors.statusFailed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleApprove() async {
    final scene = widget.scene;
    if (scene == null) return;

    try {
      await ref
          .read(sceneProvider(widget.projectId).notifier)
          .approveScene(scene.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scene approved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve: ${e.toString()}'),
            backgroundColor: AppColors.statusFailed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleLock() async {
    final scene = widget.scene;
    if (scene == null) return;

    try {
      await ref
          .read(sceneProvider(widget.projectId).notifier)
          .lockScene(scene.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scene locked'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to lock scene: ${e.toString()}'),
            backgroundColor: AppColors.statusFailed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;

    if (scene == null) {
      return _EmptyInspector();
    }

    final isLocked = scene.isLocked || scene.status == SceneStatus.locked;
    final canEdit = !isLocked;

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InspectorHeader(scene: scene),
            const SizedBox(height: 16),
            _ImagePreview(
              imageUrl: scene.imageUrl,
              sceneIndex: scene.sceneIndex,
            ),
            const SizedBox(height: 20),
            _MetaRow(scene: scene),
            const SizedBox(height: 24),
            _SectionDivider(label: 'Narration'),
            const SizedBox(height: 10),
            _isEditing && canEdit
                ? _EditableField(
                    controller: _narrationController,
                    maxLines: 6,
                  )
                : _ReadOnlyField(text: scene.narrationText),
            const SizedBox(height: 20),
            _SectionDivider(label: 'Image Prompt'),
            const SizedBox(height: 10),
            _isEditing && canEdit
                ? _EditableField(
                    controller: _imagePromptController,
                    maxLines: 4,
                  )
                : _ReadOnlyField(text: scene.imagePrompt),
            const SizedBox(height: 20),
            _SectionDivider(label: 'Animation Prompt'),
            const SizedBox(height: 10),
            _isEditing && canEdit
                ? _EditableField(
                    controller: _animationPromptController,
                    maxLines: 4,
                  )
                : _ReadOnlyField(text: scene.animationPrompt),
            const SizedBox(height: 20),
            if (scene.sfxText != null && scene.sfxText!.isNotEmpty) ...[
              _SectionDivider(label: 'Sound Effect'),
              const SizedBox(height: 10),
              _ReadOnlyField(text: scene.sfxText!),
              const SizedBox(height: 20),
            ],
            _SectionDivider(label: 'Duration'),
            const SizedBox(height: 10),
            _ReadOnlyField(
                text: '${scene.durationSec} seconds'),
            const SizedBox(height: 28),
            _ActionButtons(
              scene: scene,
              isLocked: isLocked,
              isEditing: _isEditing,
              isSaving: _isSaving,
              onEdit: canEdit
                  ? () => setState(() => _isEditing = !_isEditing)
                  : null,
              onSave: _handleSave,
              onCancel: () {
                setState(() {
                  _isEditing = false;
                  _populateFromScene(scene);
                });
              },
              onRegenerateImage: canEdit ? _handleRegenerateImage : null,
              onRegenerateText: canEdit ? _handleRegenerateText : null,
              onApprove: (canEdit &&
                      scene.status != SceneStatus.approved &&
                      scene.status != SceneStatus.locked)
                  ? _handleApprove
                  : null,
              onLock: canEdit ? _handleLock : null,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InspectorHeader extends StatelessWidget {
  final Scene scene;

  const _InspectorHeader({required this.scene});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Scene ${scene.sceneIndex + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                scene.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        StatusBadge(status: scene.status),
        if (scene.isLocked) ...[
          const SizedBox(width: 8),
          const Icon(Icons.lock_rounded, size: 16, color: AppColors.textSecondary),
        ],
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String? imageUrl;
  final int sceneIndex;

  const _ImagePreview({this.imageUrl, required this.sceneIndex});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _ImagePlaceholder(index: sceneIndex),
                errorWidget: (context, url, error) =>
                    _ImagePlaceholder(index: sceneIndex, hasError: true),
              )
            : _ImagePlaceholder(index: sceneIndex),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final int index;
  final bool hasError;

  const _ImagePlaceholder({required this.index, this.hasError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasError ? Icons.broken_image_rounded : Icons.image_outlined,
              size: 40,
              color: AppColors.textSecondary.withOpacity(0.4),
            ),
            const SizedBox(height: 8),
            Text(
              hasError ? 'Image unavailable' : 'No image yet',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final Scene scene;

  const _MetaRow({required this.scene});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetaChip(
          icon: Icons.timer_outlined,
          label: '${scene.durationSec}s',
        ),
        const SizedBox(width: 8),
        if (scene.goal != null && scene.goal!.isNotEmpty)
          Expanded(
            child: Text(
              scene.goal!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String label;

  const _SectionDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(color: AppColors.border, thickness: 1, height: 1),
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String text;

  const _ReadOnlyField({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Text(
        text.isEmpty ? '—' : text,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLines;

  const _EditableField({
    required this.controller,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.accentLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentHover, width: 2),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Scene scene;
  final bool isLocked;
  final bool isEditing;
  final bool isSaving;
  final VoidCallback? onEdit;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback? onRegenerateImage;
  final VoidCallback? onRegenerateText;
  final VoidCallback? onApprove;
  final VoidCallback? onLock;

  const _ActionButtons({
    required this.scene,
    required this.isLocked,
    required this.isEditing,
    required this.isSaving,
    this.onEdit,
    required this.onSave,
    required this.onCancel,
    this.onRegenerateImage,
    this.onRegenerateText,
    this.onApprove,
    this.onLock,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return Row(
        children: [
          Expanded(
            child: PrimaryButton(
              label: 'Save Changes',
              onPressed: isSaving ? null : onSave,
              isLoading: isSaving,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _OutlineActionButton(
              label: 'Cancel',
              icon: Icons.close_rounded,
              onPressed: onCancel,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _OutlineActionButton(
                label: 'Edit',
                icon: Icons.edit_outlined,
                onPressed: onEdit,
                isDisabled: isLocked,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _OutlineActionButton(
                label: 'Regen Image',
                icon: Icons.image_search_rounded,
                onPressed: onRegenerateImage,
                isDisabled: isLocked,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _OutlineActionButton(
                label: 'Regen Text',
                icon: Icons.text_rotation_none_rounded,
                onPressed: onRegenerateText,
                isDisabled: isLocked,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _OutlineActionButton(
                label: 'Approve',
                icon: Icons.check_circle_outline_rounded,
                onPressed: onApprove,
                isDisabled: isLocked ||
                    scene.status == SceneStatus.approved ||
                    scene.status == SceneStatus.locked,
                activeColor: const Color(0xFF2D6A1F),
                activeBgColor: AppColors.statusApproved,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _OutlineActionButton(
                label: isLocked ? 'Locked' : 'Lock Scene',
                icon: isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                onPressed: onLock,
                isDisabled: isLocked,
                activeColor: const Color(0xFF4A3FA0),
                activeBgColor: AppColors.statusLocked,
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDisabled;
  final Color? activeColor;
  final Color? activeBgColor;

  const _OutlineActionButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.isDisabled = false,
    this.activeColor,
    this.activeBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = !isDisabled && onPressed != null;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: isEnabled
            ? (activeColor ?? AppColors.textPrimary)
            : AppColors.textSecondary.withOpacity(0.4),
        backgroundColor: isEnabled && activeBgColor != null
            ? activeBgColor
            : Colors.transparent,
        side: BorderSide(
          color: isEnabled
              ? (activeColor ?? AppColors.border)
              : AppColors.border.withOpacity(0.5),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      onPressed: isEnabled ? onPressed : null,
      icon: Icon(icon, size: 14),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _EmptyInspector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: const Icon(
                Icons.touch_app_rounded,
                size: 28,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select a scene',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Click any scene card to inspect it.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}