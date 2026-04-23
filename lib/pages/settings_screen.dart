import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:life_line_admin/providers/settings_page_provider.dart';
import 'package:life_line_admin/styles/styles.dart';
import 'package:life_line_admin/widgets/nav_bar.dart';
import 'package:life_line_admin/pages/admin_dasboard.dart';
import 'package:life_line_admin/widgets/settings_card_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  FirebaseFirestore? _firestore;
  // Controllers for form fields (UI only)
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softBackground,
      drawer: buildDrawer(context),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet =
                constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    border: Border.all(color: AppColors.borderColor, width: 1),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? AppSpacing.lg : AppSpacing.xxl,
                    vertical: isMobile ? AppSpacing.md : AppSpacing.lg,
                  ),
                  child: const NavBar(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      isMobile ? AppSpacing.lg : AppSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(isMobile),
                        SizedBox(
                          height: isMobile ? AppSpacing.lg : AppSpacing.xxl,
                        ),
                        _buildSettingsSections(isMobile, isTablet),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryMaroon.withValues(alpha: 0.05),
            AppColors.accentRose.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryMaroon.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryMaroon,
              borderRadius: BorderRadius.circular(12),
            ),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const AdminDashboard(),
                      ),
                    );
                  }
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure system preferences and account settings',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSections(bool isMobile, bool isTablet) {
    return Column(
      children: [
        _buildAccountSecuritySection(isMobile),
        SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
        Consumer(
          builder: (context, ref, child) {
            return _buildNgoManagementSection(isMobile, ref);
          },
        ),
        SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
        _buildEmergencySystemSection(isMobile),
        SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
        _buildOperatorControlSection(isMobile),
      ],
    );
  }

  Widget _buildAccountSecuritySection(bool isMobile) {
    return SettingsCard(
      title: 'Account & Security',
      image: 'assets/images/account_security.webp',
      isMobile: isMobile,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextField(
            controller: _newPasswordController,
            label: 'New Password',
            isPassword: true,
            isMobile: isMobile,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirm New Password',
            isPassword: true,
            isMobile: isMobile,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActionButton('Update Password', AppColors.primary, () async {
            try {
              final querySnapshot = await _firestore
                  ?.collection('admin-info-database')
                  .get();
              if (querySnapshot?.docs.isNotEmpty ?? false) {
                final doc = querySnapshot!.docs.first;
                await doc.reference.update({
                  'Password': _newPasswordController.text,
                });
                if (mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Password was not updated, please try again',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('An unexpected error occurred'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            }
          }, isMobile),
        ],
      ),
    );
  }

  Widget _buildNgoManagementSection(bool isMobile, WidgetRef ref) {
    if (!mounted) return const SizedBox.shrink();
    final autoApprovalMode = ref.watch(
      settingsPageProvider.select((v) => v.autoApprovalMode),
    );
    return SettingsCard(
      title: 'NGO Management',
      image: 'assets/images/ngo_management.webp',
      isMobile: isMobile,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  autoApprovalMode ? 'Auto Approval' : 'Manual Approval',
                  style: AppText.fieldLabel.copyWith(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  autoApprovalMode
                      ? 'NGOs are automatically approved upon registration'
                      : 'NGOs require manual review before approval',
                  style: AppText.small.copyWith(fontSize: isMobile ? 12 : 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          _buildToggleSwitch(autoApprovalMode, 0),
        ],
      ),
    );
  }

  Widget _buildEmergencySystemSection(bool isMobile) {
    return SettingsCard(
      title: 'Emergency System',
      image: 'assets/images/emergency_system.webp',
      isMobile: isMobile,
      child: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              if (!mounted) return const SizedBox.shrink();
              final sosSystemEnabled = ref.watch(
                settingsPageProvider.select((v) => v.sosSystemEnabled),
              );
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SOS System',
                          style: AppText.fieldLabel.copyWith(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sosSystemEnabled
                              ? 'System is active'
                              : 'System is disabled',
                          style: AppText.small.copyWith(
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _buildToggleSwitch(sosSystemEnabled, 1),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Consumer(
            builder: (context, ref, child) {
              if (!mounted) return const SizedBox.shrink();
              final systemMaintenance = ref.watch(
                settingsPageProvider.select((v) => v.systemMaintenance),
              );
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: systemMaintenance
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: systemMaintenance
                            ? AppColors.warning.withValues(alpha: 0.3)
                            : AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: systemMaintenance
                                ? AppColors.warning
                                : AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          systemMaintenance ? 'Maintenance' : 'Active',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            color: systemMaintenance
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: _buildActionButton(
                      systemMaintenance
                          ? 'Exit Maintenance'
                          : 'Enter Maintenance',
                      systemMaintenance ? AppColors.success : AppColors.warning,
                      () {
                        if (mounted) {
                          ref
                              .read(settingsPageProvider.notifier)
                              .setSystemMaintenance(!systemMaintenance);
                        }
                      },
                      isMobile,
                      isCompact: true,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorControlSection(bool isMobile) {
    return SettingsCard(
      title: 'Operator Control',
      image: 'assets/images/operator_control.webp',
      isMobile: isMobile,
      child: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              if (!mounted) return const SizedBox.shrink();
              final operatorsEnabled = ref.watch(
                settingsPageProvider.select((v) => v.operatorsEnabled),
              );
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enable Operators',
                          style: AppText.fieldLabel.copyWith(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          operatorsEnabled
                              ? 'Operators can access the system'
                              : 'Operator access is disabled',
                          style: AppText.small.copyWith(
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _buildToggleSwitch(operatorsEnabled, 2),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Currently Active (3)',
                style: AppText.fieldLabel.copyWith(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ..._buildOperatorList(isMobile),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOperatorList(bool isMobile) {
    final operators = [
      {'name': 'John Smith', 'status': 'Online', 'lastActive': '2 min ago'},
      {'name': 'Sarah Johnson', 'status': 'Online', 'lastActive': '5 min ago'},
      {'name': 'Mike Wilson', 'status': 'Away', 'lastActive': '15 min ago'},
    ];

    return operators.map((operator) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.softBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: operator['status'] == 'Online'
                    ? AppColors.success
                    : AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    operator['name']!,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  Text(
                    '${operator['status']} • ${operator['lastActive']}',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    bool isMobile = false,
    IconData? prefixIcon,
  }) {
    return Form(
      key: _formKey,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field cannot be left empty';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isMobile ? 14 : 16,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch(bool value, int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (mounted && index == 0) {
            ref.read(settingsPageProvider.notifier).setAutoApprovalMode(!value);
          } else if (mounted && index == 1) {
            ref.read(settingsPageProvider.notifier).setSosSystemEnabled(!value);
          } else {
            if (mounted) {
              ref
                  .read(settingsPageProvider.notifier)
                  .setOperatorsEnabled(!value);
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 50,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: value ? AppColors.primary : AppColors.borderColor,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    Color color,
    VoidCallback onPressed,
    bool isMobile, {
    bool isCompact = false,
  }) {
    return Consumer(
      builder: (context, ref, child) {
        if (!mounted) return const SizedBox.shrink();
        final isLoading = ref.watch(
          settingsPageProvider.select((v) => v.isLoading),
        );
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: AppColors.surfaceLight,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? AppSpacing.lg : AppSpacing.xl,
              vertical: isCompact ? AppSpacing.sm : AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isCompact ? 8 : 12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  ),
                )
              : Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.submitButton.copyWith(
                    fontSize: isCompact
                        ? (isMobile ? 12 : 14)
                        : (isMobile ? 14 : 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
        );
      },
    );
  }
}
