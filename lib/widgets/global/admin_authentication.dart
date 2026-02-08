import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:life_line_admin/services/functions/transitions_in_pages.dart';
import 'package:life_line_admin/utils/styles.dart';
import 'package:life_line_admin/widgets/constants/constants.dart';
import 'package:life_line_admin/widgets/features/admin_dashboard/admin_dasboard.dart';
import 'package:life_line_admin/widgets/global/security_question.dart';

class AdminAuthentication extends StatefulWidget {
  const AdminAuthentication({super.key});

  @override
  State<AdminAuthentication> createState() => _AdminAuthenticationState();
}

class _AdminAuthenticationState extends State<AdminAuthentication> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _obscureTextField = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final querySnapshot = await _firestore
            .collection('admin-info-database')
            .where('Id', isEqualTo: _idController.text.trim())
            .where('Password', isEqualTo: _passwordController.text.trim())
            .limit(1)
            .get();

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (querySnapshot.docs.isNotEmpty) {
            if (mounted) {
              pageTransition(context, const AdminDashboard());
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid ID or password. Please try again.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppDecorations.pageLinearGradient,
        ),
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
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isMobile
            ? double.infinity
            : isTablet
            ? 500
            : 440,
      ),
      child: Container(
        decoration: isMobile ? null : SimpleDecoration.card(),
        padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xxxxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm Your Identity',
              style: AppText.welcomeTitle.copyWith(
                fontSize: isMobile ? 28 : 36,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Secure sign-in for authorized personnel.',
              style: AppText.subtitle.copyWith(fontSize: isMobile ? 16 : 18),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _buildForm(isMobile),
            const SizedBox(height: AppSpacing.xxl),
            _buildSubmitButton(isMobile),
            const SizedBox(height: AppSpacing.lg),
            _buildForgotPasswordLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(bool isMobile) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIdField(isMobile),
          const SizedBox(height: AppSpacing.xl),
          _buildPasswordField(isMobile),
        ],
      ),
    );
  }

  Widget _buildIdField(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Authentication ID', style: AppText.fieldLabel),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _idController,
          obscureText: _obscureTextField,
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
                    _obscureTextField
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureTextField = !_obscureTextField;
                    });
                  },
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password', style: AppText.fieldLabel),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          decoration: AppTextFields.textFieldDecoration('Enter your password')
              .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      height: isMobile ? 48 : AppSizes.submitButtonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: AppButtons.submit,
        child: _isLoading
            ? const _LoadingIndicator()
            : const Text('Confirm Identity'),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Center(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            pageTransition(context, const SecurityQuestion());
          },
          child: Text('Forgot Password?', style: AppText.link),
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
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
    );
  }
}
