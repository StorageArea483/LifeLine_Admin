import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_admin/providers/admin_auth_provider.dart';
import 'package:life_line_admin/styles/styles.dart';
import 'package:life_line_admin/pages/admin_dasboard.dart';
import 'package:life_line_admin/widgets/global/security_question.dart';

class AdminAuthentication extends ConsumerStatefulWidget {
  const AdminAuthentication({super.key});

  @override
  ConsumerState<AdminAuthentication> createState() =>
      _AdminAuthenticationState();
}

class _AdminAuthenticationState extends ConsumerState<AdminAuthentication> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (mounted) {
        ref.read(adminAuthPageProvider.notifier).setLoading(true);
      }

      try {
        final querySnapshot = await _firestore
            .collection('admin-info-database')
            .where('Id', isEqualTo: _idController.text.trim())
            .where('Password', isEqualTo: _passwordController.text.trim())
            .limit(1)
            .get();

        if (mounted) {
          ref.read(adminAuthPageProvider.notifier).setLoading(false);
          if (querySnapshot.docs.isNotEmpty) {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invalid ID or password. Please try again.'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ref.read(adminAuthPageProvider.notifier).setLoading(false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An unexpected error occurred'),
              backgroundColor: AppColors.error,
            ),
          );
        }
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
                          child: _buildCardContent(
                            isMobile: false,
                            isTablet: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: 5,
                  child: Image.asset(
                    'assets/images/rescue_img.webp',
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
                    child: _buildCardContent(
                      isMobile: isMobile,
                      isTablet: isTablet,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardContent({required bool isMobile, required bool isTablet}) {
    return Container(
      decoration: SimpleDecoration.card(),
      padding: const EdgeInsets.all(AppSpacing.xxxxl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Confirm Your Identity', style: AppText.welcomeTitle),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Secure sign-in for authorized personnel.',
              style: AppText.subtitle.copyWith(fontSize: isMobile ? 16 : 18),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const Text('Authentication ID', style: AppText.fieldLabel),
            const SizedBox(height: AppSpacing.sm),
            Consumer(
              builder: (context, ref, child) {
                if (!mounted) return const SizedBox.shrink();
                final obscureTextField = ref.watch(
                  adminAuthPageProvider.select((v) => v.obscureTextField),
                );
                return TextFormField(
                  controller: _idController,
                  obscureText: obscureTextField,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your ID';
                    }
                    return null;
                  },
                  decoration: AppTextFields.textFieldDecoration('Enter your ID')
                      .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureTextField
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            if (mounted) {
                              ref
                                  .read(adminAuthPageProvider.notifier)
                                  .toggleObscureTextField();
                            }
                          },
                        ),
                      ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text('Password', style: AppText.fieldLabel),
            const SizedBox(height: AppSpacing.sm),
            Consumer(
              builder: (context, ref, child) {
                if (!mounted) return const SizedBox.shrink();
                final obscurePassword = ref.watch(
                  adminAuthPageProvider.select((v) => v.obscurePassword),
                );
                return TextFormField(
                  controller: _passwordController,
                  obscureText: obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  decoration:
                      AppTextFields.textFieldDecoration(
                        'Enter your password',
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            if (mounted) {
                              ref
                                  .read(adminAuthPageProvider.notifier)
                                  .toggleObscurePassword();
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
                  if (!mounted) return const SizedBox.shrink();
                  final isLoading = ref.watch(
                    adminAuthPageProvider.select((v) => v.isLoading),
                  );
                  return ElevatedButton(
                    onPressed: isLoading ? null : _submitForm,
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
                        : const Text('Confirm Identity'),
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
                          builder: (context) => const SecurityQuestion(),
                        ),
                      );
                    }
                  },
                  child: const Text('Forgot Password?', style: AppText.link),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
