import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_admin/providers/change_pass_provider.dart';
import 'package:life_line_admin/styles/styles.dart';
import 'package:life_line_admin/pages/admin_authentication.dart';
import 'package:life_line_admin/widgets/global/page_message.dart';
import 'package:life_line_admin/widgets/global/page_navigation.dart';

class ChangePassword extends ConsumerStatefulWidget {
  const ChangePassword({super.key});

  @override
  ConsumerState<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends ConsumerState<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field cannot be left empty';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Field cannot be left empty';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      ref.read(changePassProvider.notifier).setIsLoading(true);
    }
    try {
      final querySnapshot = await _firestore
          .collection('admin-info-database')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (mounted) {
          ref.read(changePassProvider.notifier).setIsLoading(false);
          pageMessage('Admin record not found', context, AppColors.error);
        }
        return;
      }

      final docId = querySnapshot.docs.first.id;
      await _firestore.collection('admin-info-database').doc(docId).update({
        'Password': _confirmPasswordController.text.trim(),
      });

      if (mounted) {
        ref.read(changePassProvider.notifier).setIsLoading(false);
        pageMessage(
          'Password updated successfully',
          context,
          AppColors.success,
        );
      }
    } catch (e) {
      if (mounted) {
        ref.read(changePassProvider.notifier).setIsLoading(false);
        pageMessage('Error updating password', context, AppColors.error);
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
                          child: _buildMainContent(false, false),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: 5,
                  child: Image.asset(
                    'assets/images/rescue_img2.webp',
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
                    child: _buildMainContent(isMobile, isTablet),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(bool isMobile, bool isTablet) {
    return Container(
      decoration: SimpleDecoration.card(),
      padding: const EdgeInsets.all(AppSpacing.xxxxl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Restore Your Password', style: AppText.welcomeTitle),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Please enter your new password below. It must be at least 8 characters long.',
              style: AppText.subtitle.copyWith(fontSize: isMobile ? 16 : 18),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const Text('Enter your new password', style: AppText.fieldLabel),
            const SizedBox(height: AppSpacing.sm),
            Consumer(
              builder: (context, ref, child) {
                final obscureNewPassword = ref.watch(
                  changePassProvider.select((v) => v.obscureNewPassword),
                );
                return TextFormField(
                  controller: _newPasswordController,
                  obscureText: obscureNewPassword,
                  validator: _validateNewPassword,
                  decoration:
                      AppTextFields.textFieldDecoration(
                        'Enter new password',
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNewPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            if (mounted) {
                              ref
                                  .read(changePassProvider.notifier)
                                  .toggleObscureNewPassword();
                            }
                          },
                        ),
                      ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text('Confirm your new password', style: AppText.fieldLabel),
            const SizedBox(height: AppSpacing.sm),
            Consumer(
              builder: (context, ref, child) {
                final obscureConfirmPassword = ref.watch(
                  changePassProvider.select((v) => v.obscureConfirmPassword),
                );
                return TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  decoration:
                      AppTextFields.textFieldDecoration(
                        'Confirm new password',
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            if (mounted) {
                              ref
                                  .read(changePassProvider.notifier)
                                  .toggleObscureConfirmPassword();
                            }
                          },
                        ),
                      ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: double.infinity,
              height: isMobile ? 48 : AppSizes.submitButtonHeight,
              child: Consumer(
                builder: (context, ref, child) {
                  final isLoading = ref.watch(
                    changePassProvider.select((v) => v.isLoading),
                  );
                  return ElevatedButton(
                    onPressed: isLoading ? null : _handleResetPassword,
                    style: AppButtons.submit,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.surfaceLight,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Reset Password'),
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
                      pageNavigation(const AdminAuthentication(), context);
                    }
                  },
                  child: const Text('Back to Login', style: AppText.link),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
