
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animuse/core/theme/app_colors.dart';
import 'package:animuse/core/theme/app_text_styles.dart';
import 'package:animuse/widgets/primary_button.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 64.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _AnimuseLogo(),
                const SizedBox(height: 48),
                Text(
                  'Turn any topic into a storyboarded video',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Topic → Script → Scenes → Animation',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 20,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 56),
                PrimaryButton(
                  label: 'Enter Studio',
                  onPressed: () => context.go('/create'),
                ),
                const SizedBox(height: 48),
                _FeatureRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimuseLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.movie_filter_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Animuse',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      (Icons.auto_awesome_rounded, 'AI Script'),
      (Icons.view_module_rounded, 'Storyboard'),
      (Icons.image_rounded, 'Scene Images'),
      (Icons.movie_creation_rounded, 'Animation'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: features.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;
        return Row(
          children: [
            _FeatureChip(icon: feature.$1, label: feature.$2),
            if (index < features.length - 1) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 8),
            ],
          ],
        );
      }).toList(),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}