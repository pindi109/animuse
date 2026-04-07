
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animuse/core/theme/app_colors.dart';
import 'package:animuse/core/theme/app_text_styles.dart';
import 'package:animuse/providers/project_provider.dart';
import 'package:animuse/widgets/primary_button.dart';
import 'package:animuse/widgets/app_text_field.dart';
import 'package:animuse/widgets/loading_overlay.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _audienceController = TextEditingController();
  final _visualStyleController = TextEditingController();

  String _selectedTone = 'Cinematic';
  String _selectedVoice = 'Neutral';
  bool _isGenerating = false;

  static const _toneOptions = [
    'Cinematic',
    'Documentary',
    'Educational',
    'Explainer',
    'Dramatic',
  ];

  static const _voiceOptions = [
    'Neutral',
    'Warm',
    'Authoritative',
    'Friendly',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    _objectiveController.dispose();
    _audienceController.dispose();
    _visualStyleController.dispose();
    super.dispose();
  }

  Future<void> _handleGenerate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGenerating = true);

    try {
      final notifier = ref.read(projectListProvider.notifier);

      final projectId = await notifier.createAndGenerate(
        topic: _topicController.text.trim(),
        tone: _selectedTone,
        objective: _objectiveController.text.trim().isEmpty
            ? null
            : _objectiveController.text.trim(),
        audience: _audienceController.text.trim().isEmpty
            ? null
            : _audienceController.text.trim(),
        visualStyle: _visualStyleController.text.trim().isEmpty
            ? null
            : _visualStyleController.text.trim(),
        voicePreset: _selectedVoice,
      );

      if (mounted) {
        context.go('/workspace/$projectId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create project: ${e.toString()}'),
            backgroundColor: AppColors.statusFailed,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _handleGenerate,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isGenerating,
      message: 'Generating your storyboard…',
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32.0, vertical: 40.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 40),
                        _buildForm(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => context.go('/'),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.movie_filter_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Animuse',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          'Create a new project',
          style: AppTextStyles.displayLarge.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Describe your topic and we\'ll generate a full storyboard.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(label: 'Topic', isRequired: true),
          const SizedBox(height: 8),
          AppTextField(
            controller: _topicController,
            hintText:
                'e.g. The history of space exploration and its impact on modern technology',
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Topic is required';
              }
              if (value.trim().length < 5) {
                return 'Topic must be at least 5 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Tone / Style'),
          const SizedBox(height: 8),
          _StyledDropdown(
            value: _selectedTone,
            items: _toneOptions,
            onChanged: (value) {
              if (value != null) setState(() => _selectedTone = value);
            },
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Video Objective'),
          const SizedBox(height: 8),
          AppTextField(
            controller: _objectiveController,
            hintText: 'e.g. Educate viewers on key milestones and breakthroughs',
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Target Audience'),
          const SizedBox(height: 8),
          AppTextField(
            controller: _audienceController,
            hintText: 'e.g. General public, high school students, professionals',
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Scene Visual Style Notes'),
          const SizedBox(height: 8),
          AppTextField(
            controller: _visualStyleController,
            hintText:
                'e.g. Photorealistic, dramatic lighting, wide-angle shots with epic scale',
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          _SectionLabel(label: 'Voice Preset'),
          const SizedBox(height: 8),
          _StyledDropdown(
            value: _selectedVoice,
            items: _voiceOptions,
            onChanged: (value) {
              if (value != null) setState(() => _selectedVoice = value);
            },
          ),
          const SizedBox(height: 40),
          PrimaryButton(
            label: 'Generate Storyboard',
            onPressed: _isGenerating ? null : _handleGenerate,
            isLoading: _isGenerating,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const _SectionLabel({required this.label, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ],
      ],
    );
  }
}

class _StyledDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}