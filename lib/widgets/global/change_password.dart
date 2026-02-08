import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:life_line_admin/services/functions/transitions_in_pages.dart';
import 'package:life_line_admin/utils/styles.dart';
import 'package:life_line_admin/widgets/constants/constants.dart';
import 'package:life_line_admin/widgets/global/admin_authentication.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

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

    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await _firestore
          .collection('admin-info-database')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admin record not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final docId = querySnapshot.docs.first.id;
      await _firestore.collection('admin-info-database').doc(docId).update({
        'Password': _confirmPasswordController.text.trim(),
      });

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating password: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppContainers.pageContainer,
        child: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final isTablet =
                    constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? AppSpacing.lg : AppSpacing.xl,
                    vertical: isMobile ? AppSpacing.lg : AppSpacing.xxl,
                  ),
                  child: _buildMainContent(isMobile, isTablet),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(bool isMobile, bool isTablet) {
    return Container(
      decoration: isMobile ? null : SimpleDecoration.card(),
      padding: EdgeInsets.all(isMobile ? 0 : AppSpacing.xxxxl),
      constraints: BoxConstraints(
        maxWidth: isMobile
            ? double.infinity
            : isTablet
            ? 500
            : 440,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restore Your Password',
              style: AppText.welcomeTitle.copyWith(
                fontSize: isMobile ? 28 : 36,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Please enter your new password below. It must be at least 8 characters long.',
              style: AppText.subtitle.copyWith(fontSize: isMobile ? 16 : 18),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildNewPasswordField(isMobile),
            const SizedBox(height: AppSpacing.xl),
            _buildConfirmPasswordField(isMobile),
            const SizedBox(height: AppSpacing.xxl),
            _buildResetButton(isMobile),
            const SizedBox(height: AppSpacing.lg),
            _buildBackToLoginLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildNewPasswordField(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter your new password', style: AppText.fieldLabel),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscureNewPassword,
          validator: _validateNewPassword,
          decoration: AppTextFields.textFieldDecoration('Enter new password')
              .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm your new password', style: AppText.fieldLabel),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          validator: _validateConfirmPassword,
          decoration: AppTextFields.textFieldDecoration('Confirm new password')
              .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildResetButton(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      height: isMobile ? 48 : AppSizes.submitButtonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleResetPassword,
        style: AppButtons.submit,
        child: _isLoading
            ? const _LoadingIndicator()
            : const Text('Reset Password'),
      ),
    );
  }

  Widget _buildBackToLoginLink() {
    return Center(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            pageTransition(context, const AdminAuthentication());
          },
          child: Text('Back to Login', style: AppText.link),
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}
