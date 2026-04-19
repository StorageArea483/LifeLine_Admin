import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_admin/pages/admin_authentication.dart';
import 'package:life_line_admin/providers/admin_page_provider.dart';
import 'package:life_line_admin/styles/styles.dart';
import 'package:life_line_admin/widgets/nav_bar.dart';
import 'package:life_line_admin/pages/show_ngo_info.dart';
import 'package:life_line_admin/pages/show_victim_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  FirebaseFirestore? _ngoFirestore;

  // life-line-ngo project credentials
  static const FirebaseOptions _ngoFirebaseOptions = FirebaseOptions(
    apiKey:
        'AIzaSyBeieryGaw4bh4dtbrI54qsIc51XkP6SoM', // Get from life-line-ngo project settings
    appId: '1:169949190544:web:2640453ce5dd2aa55d3b15',
    messagingSenderId: '169949190544',
    projectId: 'life-line-ngo',
    authDomain: 'life-line-ngo.firebaseapp.com',
    storageBucket: 'life-line-ngo.firebasestorage.app',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSecondaryFirebase();
    });
  }

  Future<void> _initSecondaryFirebase() async {
    if (mounted) {
      ref.read(adminPageProvider.notifier).setLoading(true);
    }
    try {
      // Initialize secondary Firebase app for life-line-ngo
      final secondaryApp = await Firebase.initializeApp(
        name: 'life-line-ngo',
        options: _ngoFirebaseOptions,
      );
      _ngoFirestore = FirebaseFirestore.instanceFor(app: secondaryApp);

      await _checkNgoRegistration();
    } catch (e) {
      if (mounted) {
        ref.read(adminPageProvider.notifier).setLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred, please re-login'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AdminAuthentication()),
        );
      }
    }
  }

  Future<void> _checkNgoRegistration() async {
    if (_ngoFirestore == null) return;

    try {
      final snapshot = await _ngoFirestore!
          .collection('ngo-info-database')
          .get();
      if (mounted) {
        ref.read(adminPageProvider.notifier).setLoading(false);
        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final isApproved = data['approved'] ?? false;

            // Only add NGOs that are NOT approved (pending requests)
            if (!isApproved && mounted) {
              ref.read(adminPageProvider.notifier).addNgoRequest({
                'docId': doc.id,
                'name': data['ngoName'] ?? 'Unknown NGO',
                'logo': data['ngoLogo'] ?? '',
                'directorName': data['directorName'] ?? '',
                'projectManager': data['projectManager'] ?? '',
                'registrationNumber': data['registrationNumber'] ?? '',
                'selectedProgram': data['selectedProgram'] ?? '',
                'phoneNumber': data['phone'] ?? '',
                'email': data['email'] ?? '',
                'address': data['address'] ?? '',
                'geographicalCoverage': data['geographicalCoverage'] ?? '',
                'pastExperience': data['pastExperience'] ?? '',
                'documentUrl': data['documentUrl'] ?? '',
                'approved': isApproved,
                'branchName': data['branchName'] ?? '',
              });
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ref.read(adminPageProvider.notifier).setLoading(false);
      }
    }
  }

  Future<void> _handleNgoAction(
    BuildContext context,
    Map<String, dynamic> ngo,
    bool isApproved,
  ) async {
    if (_ngoFirestore == null) return;

    try {
      if (isApproved) {
        await _ngoFirestore!
            .collection('ngo-info-database')
            .doc(ngo['docId'])
            .update({'approved': true});
        if (mounted) {
          ref.invalidate(adminPageProvider);
        }
      } else {
        await _ngoFirestore!
            .collection('ngo-info-database')
            .doc(ngo['docId'])
            .delete();
      }

      if (mounted) {
        ref
            .read(adminPageProvider)
            .ngoRequests
            .removeWhere((item) => item['docId'] == ngo['docId']);

        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isApproved
                    ? 'NGO approved successfully'
                    : 'NGO request disapproved',
              ),
              backgroundColor: isApproved ? AppColors.success : AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showNgoDetails(BuildContext context, Map<String, dynamic> ngo) {
    showDialog(
      context: context,
      barrierColor: AppColors.overlay,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('View NGO Details', style: AppText.formTitle),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if (mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                          child: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildDetailRow('NGO Name', ngo['name']),
                  _buildDetailRow('Director Name', ngo['directorName']),
                  _buildDetailRow('Project Manager', ngo['projectManager']),
                  _buildDetailRow(
                    'Registration Number',
                    ngo['registrationNumber'],
                  ),
                  _buildDetailRow('Selected Program', ngo['selectedProgram']),
                  _buildDetailRow('Phone Number', ngo['phoneNumber']),
                  _buildDetailRow('Email', ngo['email']),
                  _buildDetailRow('Address', ngo['address']),
                  _buildDetailRow(
                    'Geographical Coverage',
                    ngo['geographicalCoverage'],
                  ),
                  _buildDetailRow('Past Experience', ngo['pastExperience']),
                  _buildDetailRow('Branch Name', ngo['branchName']),
                  const SizedBox(height: AppSpacing.xxl),
                  if (ngo['documentUrl'] != null &&
                      ngo['documentUrl'].toString().isNotEmpty)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          try {
                            final url = Uri.parse(ngo['documentUrl']);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Error downloading document, please retry',
                                  ),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          'Download Document',
                          style: AppText.link.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    children: [
                      Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () =>
                                _handleNgoAction(dialogContext, ngo, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'Approve',
                                  style: AppText.submitButton,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () =>
                                _handleNgoAction(dialogContext, ngo, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'Disapprove',
                                  style: AppText.submitButton,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: AppText.small.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: AppText.fieldLabel,
            ),
          ),
        ],
      ),
    );
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
                final isCompact = isMobile || isTablet;

                return Column(
                  children: [
                    _NavBarContainer(isMobile: isMobile),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(
                          isMobile ? AppSpacing.lg : AppSpacing.xxl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildActionButtons(context, isCompact),
                            const SizedBox(height: AppSpacing.xxl),
                            _buildStatusSection(isMobile, isCompact),
                            const SizedBox(height: AppSpacing.xl),
                            _buildNotificationsSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isCompact) {
    final actionButtons = [
      {
        'title': 'View Users',
        'icon': Icons.people_outline,
        'onTap': () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ShowVictimInfo()),
            );
          }
        },
      },
      {
        'title': 'View NGOs',
        'icon': Icons.business_outlined,
        'onTap': () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const ShowNgoInfo()),
            );
          }
        },
      },
      {
        'title': 'View Rescuers',
        'icon': Icons.volunteer_activism_outlined,
        'onTap': () {},
      },
    ];

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: actionButtons
            .map(
              (btn) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _ActionCard(
                  title: btn['title'] as String,
                  icon: btn['icon'] as IconData,
                  onTap: btn['onTap'] as VoidCallback,
                ),
              ),
            )
            .toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: actionButtons
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xl),
                child: _ActionCard(
                  title: entry.value['title'] as String,
                  icon: entry.value['icon'] as IconData,
                  onTap: entry.value['onTap'] as VoidCallback,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildStatusSection(bool isMobile, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Status',
          style: AppText.appHeader.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildStatCards(isCompact),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return Consumer(
      builder: (context, ref, child) {
        if (!mounted) return const SizedBox.shrink();
        final isLoading = ref.watch(
          adminPageProvider.select((v) => v.isLoading),
        );
        if (!mounted) return const SizedBox.shrink();
        final ngoRequests = ref.watch(
          adminPageProvider.select((v) => v.ngoRequests),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NGO Pending Requests',
              style: AppText.appHeader.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: CircularProgressIndicator(
                    color: AppColors.primaryMaroon,
                  ),
                ),
              )
            else if (ngoRequests.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: SimpleDecoration.card(),
                child: const Center(
                  child: Text('No pending requests', style: AppText.subtitle),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ngoRequests.length,
                itemBuilder: (context, index) {
                  final ngo = ngoRequests[index];
                  final logoUrl = ngo['logo'] ?? '';
                  final ngoName = ngo['name'] ?? 'Unknown NGO';

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: SimpleDecoration.card(),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.borderLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              logoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.business,
                                  color: AppColors.primaryMaroon,
                                  size: 24,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Text(ngoName, style: AppText.fieldLabel),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Pending',
                            style: AppText.small.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Builder(
                          builder: (builderContext) {
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () =>
                                    _showNgoDetails(builderContext, ngo),
                                child: const Icon(
                                  Icons.read_more,
                                  color: AppColors.warning,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: AppSpacing.md),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              Icons.close,
                              color: AppColors.warning,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatCards(bool isCompact) {
    final stats = [
      {
        'title': 'Active Users',
        'value': '1,452',
        'percentage': '+5.2%',
        'isPositive': true,
      },
      {
        'title': 'Registered NGOs',
        'value': '87',
        'percentage': '+1.5%',
        'isPositive': true,
      },
      {
        'title': 'Ongoing Operations',
        'value': '12',
        'percentage': '-3.0%',
        'isPositive': false,
      },
    ];

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: stats
            .map(
              (stat) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _StatCard(
                  title: stat['title'] as String,
                  value: stat['value'] as String,
                  percentage: stat['percentage'] as String,
                  percentageColor: (stat['isPositive'] as bool)
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            )
            .toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: stats
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  right: entry.key < stats.length - 1 ? AppSpacing.xl : 0,
                ),
                child: SizedBox(
                  width: 280,
                  child: _StatCard(
                    title: entry.value['title'] as String,
                    value: entry.value['value'] as String,
                    percentage: entry.value['percentage'] as String,
                    percentageColor: (entry.value['isPositive'] as bool)
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// Extracted Widgets
class _NavBarContainer extends StatelessWidget {
  final bool isMobile;
  const _NavBarContainer({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.lg : AppSpacing.xxl,
        vertical: isMobile ? AppSpacing.md : AppSpacing.lg,
      ),
      child: const NavBar(),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: SimpleDecoration.card(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primaryMaroon, size: 24),
              const SizedBox(width: AppSpacing.md),
              Text(
                title,
                style: AppText.fieldLabel.copyWith(
                  color: AppColors.darkCharcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String percentage;
  final Color percentageColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.percentage,
    required this.percentageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: SimpleDecoration.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppText.fieldLabel.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppText.welcomeTitle.copyWith(
              fontSize: 32,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            percentage,
            style: AppText.small.copyWith(
              color: percentageColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
