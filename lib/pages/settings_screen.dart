import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:life_line_admin/providers/settings_page_provider.dart';
import 'package:life_line_admin/styles/styles.dart';
import 'package:life_line_admin/widgets/global/page_message.dart';
import 'package:life_line_admin/widgets/global/page_navigation.dart';
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

  // Controllers for form fields (UI only)
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((value) {
      initialize();
    });
  }

  Future<void> initialize() async {
    if (mounted) {
      ref.read(settingsPageProvider.notifier).setLoading(true);
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('settings')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final settingsData = querySnapshot.docs.first.data();

        // Fetch and set all settings values
        final autoApproved = settingsData['auto approved'] ?? false;
        final sosDisabled = settingsData['sos disabled'] ?? false;
        final maintenance = settingsData['maintenance'] ?? false;

        if (mounted) {
          ref
              .read(settingsPageProvider.notifier)
              .setAutoApprovalMode(autoApproved);
          ref
              .read(settingsPageProvider.notifier)
              .setSosSystemEnabled(sosDisabled);
          ref
              .read(settingsPageProvider.notifier)
              .setSystemMaintenance(maintenance);
        }
      }
    } catch (e) {
      if (mounted) {
        pageMessage('An unexpected error occurred', context, AppColors.error);
      }
    } finally {
      if (mounted) {
        ref.read(settingsPageProvider.notifier).setLoading(false);
      }
    }
  }

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
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                final isTablet =
                    constraints.maxWidth >= 600 && constraints.maxWidth < 1024;

                return Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 1,
                        ),
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
            Consumer(
              builder: (context, ref, child) {
                final isLoading = ref.watch(
                  settingsPageProvider.select((v) => v.isLoading),
                );
                if (!isLoading) return const SizedBox.shrink();
                return IgnorePointer(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryMaroon,
                          strokeWidth: 4,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
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
                    pageNavigation(const AdminDashboard(), context);
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
      ],
    );
  }

  Widget _buildAccountSecuritySection(bool isMobile) {
    return SettingsCard(
      title: 'Account & Security',
      image: 'assets/images/account_security.webp',
      isMobile: isMobile,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTextField(
              controller: _newPasswordController,
              label: 'New Password',
              isMobile: isMobile,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              isMobile: isMobile,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field cannot be left empty';
                }
                if (value != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _buildActionButton('Update Password', AppColors.primary, () async {
              if (_formKey.currentState!.validate()) {
                if (mounted) {
                  ref.read(settingsPageProvider.notifier).setLoading(true);
                }
                try {
                  final querySnapshot = await FirebaseFirestore.instance
                      .collection('admin-info-database')
                      .get();
                  if (querySnapshot.docs.isNotEmpty) {
                    final doc = querySnapshot.docs.first;
                    await doc.reference.update({
                      'Password': _newPasswordController.text,
                    });
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      pageMessage('Password updated successfully', context, AppColors.success);
                    }
                  } else {
                    if (mounted) {
                      pageMessage('Failed to update password', context, AppColors.error);
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    pageMessage('An unexpected error occurred', context, AppColors.error);
                  }
                } finally {
                  if (mounted) {
                    _newPasswordController.text = '';
                    _confirmPasswordController.text = '';
                    ref.read(settingsPageProvider.notifier).setLoading(false);
                  }
                }
              }
            }, isMobile),
          ],
        ),
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
                              ? 'System is disabled'
                              : 'System is active',
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
                      () async {
                        if (mounted) {
                          ref
                              .read(settingsPageProvider.notifier)
                              .setLoading(true);
                          try {
                            final querySnapshot = await FirebaseFirestore
                                .instance
                                .collection('settings')
                                .get();

                            if (querySnapshot.docs.isNotEmpty) {
                              // Document exists, update it
                              await querySnapshot.docs.first.reference.update({
                                'maintenance': !systemMaintenance,
                              });
                            } else {
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                pageMessage('Failed to process your request', context, AppColors.error);
                              }
                            }
                            if (mounted) {
                              ref
                                  .read(settingsPageProvider.notifier)
                                  .setSystemMaintenance(!systemMaintenance);
                            }
                          } catch (e) {
                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              pageMessage('An unexpected error occurred', context, AppColors.error);
                            }
                          } finally {
                            if (mounted) {
                              ref
                                  .read(settingsPageProvider.notifier)
                                  .setLoading(false);
                            }
                          }
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isMobile = false,
    IconData? prefixIcon,
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextFormField(
        controller: controller,
        validator:
            validator ??
            (value) {
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
    );
  }

  Widget _buildToggleSwitch(bool value, int index) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          if (mounted && index == 0) {
            ref.read(settingsPageProvider.notifier).setLoading(true);
            try {
              final querySnapshot = await FirebaseFirestore.instance
                  .collection('settings')
                  .get();

              if (querySnapshot.docs.isNotEmpty) {
                // Document exists, update it
                await querySnapshot.docs.first.reference.update({
                  'auto approved': !value,
                });
              } else {
                if (mounted) {
                  pageMessage('Failed to process your request', context, AppColors.error);
                }
              }

              if (mounted) {
                ref
                    .read(settingsPageProvider.notifier)
                    .setAutoApprovalMode(!value);
              }
            } catch (e) {
              if (mounted) {
                pageMessage('An unexpected error occurred', context, AppColors.error);
              }
            } finally {
              if (mounted) {
                ref.read(settingsPageProvider.notifier).setLoading(false);
              }
            }
          } else if (mounted && index == 1) {
            ref.read(settingsPageProvider.notifier).setLoading(true);
            try {
              final querySnapshot = await FirebaseFirestore.instance
                  .collection('settings')
                  .get();

              if (querySnapshot.docs.isNotEmpty) {
                // Document exists, update it
                await querySnapshot.docs.first.reference.update({
                  'sos disabled': !value,
                });
              } else {
                if (mounted) {
                  pageMessage('Failed to process your request', context, AppColors.error);
                }
              }

              if (mounted) {
                ref
                    .read(settingsPageProvider.notifier)
                    .setSosSystemEnabled(!value);
              }
            } catch (e) {
              if (mounted) {
                pageMessage('An unexpected error occurred', context, AppColors.error);
              }
            } finally {
              if (mounted) {
                ref.read(settingsPageProvider.notifier).setLoading(false);
              }
            }
            // End SOS system toggle
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
    Future<void> Function() onPressed,
    bool isMobile, {
    bool isCompact = false,
  }) {
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
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: AppText.submitButton.copyWith(
          fontSize: isCompact ? (isMobile ? 12 : 14) : (isMobile ? 14 : 16),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
