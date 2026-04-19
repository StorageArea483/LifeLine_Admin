import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_admin/providers/security_question_provider.dart';
import 'package:life_line_admin/styles/styles.dart';
import 'package:life_line_admin/pages/admin_authentication.dart';
import 'package:life_line_admin/widgets/global/change_password.dart';
import 'package:life_line_admin/widgets/global/loading_indicator.dart';

class SecurityQuestion extends ConsumerStatefulWidget {
  const SecurityQuestion({super.key});

  @override
  ConsumerState<SecurityQuestion> createState() => _SecurityQuestionState();
}

class _SecurityQuestionState extends ConsumerState<SecurityQuestion> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _securityAnswerController =
      TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _securityAnswerController.dispose();
    super.dispose();
  }

  String? _validateSecurityAnswer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field cannot be left empty';
    }
    return null;
  }

  Future<void> _handleRestorePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      ref.read(securityPageProvider.notifier).state = true;
    }

    try {
      final querySnapshot = await _firestore
          .collection('admin-info-database')
          .where('object', isEqualTo: _securityAnswerController.text.trim())
          .limit(1)
          .get();

      if (mounted) {
        ref.read(securityPageProvider.notifier).state = false;
        if (querySnapshot.docs.isNotEmpty && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const ChangePassword()),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Incorrect security answer. Please try again.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ref.read(securityPageProvider.notifier).state = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          final isDesktop = constraints.maxWidth >= 1024;

          if (isDesktop) {
            return Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: AppDecorations.pageLinearGradient,
                    ),
                    child: Center(
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 470),
                          child: _buildMainCard(false, false),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: 5,
                  child: Image.asset(
                    'assets/images/rescue_img3.webp',
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
              ],
            );
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: AppDecorations.pageLinearGradient,
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 500 : double.infinity,
                    ),
                    child: _buildMainCard(isMobile, isTablet),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainCard(bool isMobile, bool isTablet) {
    return Container(
      decoration: SimpleDecoration.card(),
      padding: const EdgeInsets.all(AppSpacing.xxxxl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Let\'s restore your password',
              style: AppText.welcomeTitle,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'To continue, please answer your security question below.',
              style: AppText.formDescription.copyWith(
                fontSize: isMobile ? 14 : 16,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const Text('Security Question', style: AppText.fieldLabel),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _securityAnswerController,
              validator: _validateSecurityAnswer,
              decoration: AppTextFields.textFieldDecoration(
                'Name of your favorite object',
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              height: isMobile ? 48 : AppSizes.submitButtonHeight,
              child: Consumer(
                builder: (context, ref, child) {
                  if (!mounted) return const SizedBox.shrink();
                  final isLoading = ref.watch(securityPageProvider);
                  return ElevatedButton(
                    onPressed: isLoading ? null : _handleRestorePassword,
                    style: AppButtons.submit,
                    child: isLoading
                        ? const LoadingIndicator()
                        : const Text('Restore Password'),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const AdminAuthentication(),
                        ),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: AppColors.primaryMaroon,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text('Back to Login', style: AppText.link),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
