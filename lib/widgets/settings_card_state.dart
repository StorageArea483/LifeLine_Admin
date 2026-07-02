import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_admin/providers/settings_page_provider.dart';
import 'package:life_line_admin/styles/styles.dart';

class SettingsCard extends ConsumerStatefulWidget {
  final String title;
  final String image;
  final Widget child;
  final bool isMobile;

  const SettingsCard({
    super.key,
    required this.title,
    required this.image,
    required this.child,
    required this.isMobile,
  });

  @override
  ConsumerState<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends ConsumerState<SettingsCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkCharcoal.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if (mounted) {
                  // Toggle the expanded state for this specific card
                  final currentState = ref.read(
                    settingsCardExpandedProvider(widget.title),
                  );
                  ref
                          .read(
                            settingsCardExpandedProvider(widget.title).notifier,
                          )
                          .state =
                      !currentState;
                }
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      widget.image,
                      width: widget.isMobile ? 25 : 30,
                      height: widget.isMobile ? 25 : 30,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: AppText.fieldLabel.copyWith(
                          fontSize: widget.isMobile ? 16 : 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final isExpanded = ref.watch(
                          settingsCardExpandedProvider(widget.title),
                        );
                        return AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary,
                            size: widget.isMobile ? 20 : 24,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Consumer(
            builder: (context, ref, child) {
              final isExpanded = ref.watch(
                settingsCardExpandedProvider(widget.title),
              );
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isExpanded ? null : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isExpanded ? 1.0 : 0.0,
                  child: isExpanded
                      ? Container(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xl,
                            0,
                            AppSpacing.xl,
                            AppSpacing.xl,
                          ),
                          child: widget.child,
                        )
                      : const SizedBox.shrink(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
