import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_line_admin/services/functions/transitions_in_pages.dart';
import 'package:life_line_admin/utils/styles.dart';
import 'package:life_line_admin/widgets/constants/constants.dart';
import 'package:life_line_admin/widgets/global/admin_authentication.dart';
import 'package:life_line_admin/widgets/global/change_password.dart';

class SecurityQuestion extends StatefulWidget {
  const SecurityQuestion({super.key});

  @override
  State<SecurityQuestion> createState() => _SecurityQuestionState();
}

class _SecurityQuestionState extends State<SecurityQuestion> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _securityAnswerController =
      TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

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

    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await _firestore
          .collection('admin-info-database')
          .where('object', isEqualTo: _securityAnswerController.text.trim())
          .limit(1)
          .get();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (querySnapshot.docs.isNotEmpty) {
          pageTransition(context, const ChangePassword());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incorrect security answer. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
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
                  child: _buildMainCard(isMobile, isTablet),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(bool isMobile, bool isTablet) {
    return Container(
      decoration: isMobile ? null : SimpleDecoration.card(),
      padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xxxxl),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Let\'s restore your password',
              style: AppText.welcomeTitle.copyWith(
                fontSize: isMobile ? 28 : 36,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'To continue, please answer your security question below.',
              style: AppText.formDescription.copyWith(
                fontSize: isMobile ? 14 : 16,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Security Question', style: AppText.fieldLabel),
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
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRestorePassword,
                style: AppButtons.submit,
                child: _isLoading
                    ? const _LoadingIndicator()
                    : const Text('Restore Password'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    pageTransition(context, const AdminAuthentication());
                  },
                  child: const _BackToLoginLink(),
                ),
              ),
            ),
          ],
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

class _BackToLoginLink extends StatelessWidget {
  const _BackToLoginLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.arrow_back, size: 16, color: AppColors.primaryMaroon),
        const SizedBox(width: AppSpacing.xs),
        Text('Back to Login', style: AppText.link),
      ],
    );
  }
}
