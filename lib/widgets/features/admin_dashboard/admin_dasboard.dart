import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:life_line_admin/services/functions/transitions_in_pages.dart';
import 'package:life_line_admin/utils/styles.dart';
import 'package:life_line_admin/widgets/constants/constants.dart';
import 'package:life_line_admin/services/functions/nav_bar.dart';
import 'package:life_line_admin/widgets/features/admin_dashboard/show_ngo_info.dart';
import 'package:life_line_admin/widgets/features/admin_dashboard/show_victim_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = false;
  bool _showNotification = false;
  String _notificationNgoName = '';
  final List<Map<String, dynamic>> _ngoRequests = [];
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
    _initSecondaryFirebase();
  }

  Future<void> _initSecondaryFirebase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Initialize secondary Firebase app for life-line-ngo
      final secondaryApp = await Firebase.initializeApp(
        name: 'life-line-ngo',
        options: _ngoFirebaseOptions,
      );
      _ngoFirestore = FirebaseFirestore.instanceFor(app: secondaryApp);

      await _checkNgoRegistration();
    } catch (e) {
      debugPrint('Error initializing secondary Firebase: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkNgoRegistration() async {
    if (_ngoFirestore == null) return;

    try {
      final snapshot = await _ngoFirestore!
          .collection('ngo-info-database')
          .get();
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final isApproved = data['approved'] ?? false;

            // Only add NGOs that are NOT approved (pending requests)
            if (!isApproved) {
              _ngoRequests.add({
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
          // Show notification for the first pending NGO
          if (_ngoRequests.isNotEmpty) {
            _showNotification = true;
            _notificationNgoName = _ngoRequests.first['name'] ?? 'Unknown NGO';
          }
        }
      });
    } catch (e) {
      debugPrint('Error fetching NGO data: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
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
      } else {
        await _ngoFirestore!
            .collection('ngo-info-database')
            .doc(ngo['docId'])
            .delete();
      }

      if (mounted) {
        setState(() {
          _ngoRequests.removeWhere((item) => item['docId'] == ngo['docId']);
        });

        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isApproved
                    ? 'NGO approved successfully'
                    : 'NGO request disapproved',
              ),
              backgroundColor: isApproved ? Colors.green : Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating NGO: $e');
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
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: Colors.white,
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
                      Text('View NGO Details', style: AppText.formTitle),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => Navigator.of(dialogContext).pop(),
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
                          final url = Uri.parse(ngo['documentUrl']);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
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
                              child: Center(
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
                              child: Center(
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
            if (_showNotification)
              Positioned(
                top: AppSpacing.xxl,
                right: AppSpacing.xxl,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: SimpleDecoration.card(),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications,
                          color: AppColors.primaryMaroon,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'A new NGO got registered: $_notificationNgoName',
                            style: AppText.base.copyWith(fontSize: 13),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showNotification = false;
                            });
                          },
                          child: const Icon(Icons.close, size: 18),
                        ),
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

  Widget _buildActionButtons(BuildContext context, bool isCompact) {
    final cards = [
      _ActionCardData(
        title: 'View Users',
        icon: Icons.people_outline,
        onTap: () => pageTransition(context, const ShowVictimInfo()),
      ),
      _ActionCardData(
        title: 'View NGOs',
        icon: Icons.business_outlined,
        onTap: () {
          pageTransition(context, const ShowNgoInfo());
        },
      ),
      _ActionCardData(
        title: 'View Rescuers',
        icon: Icons.volunteer_activism_outlined,
        onTap: () {},
      ),
    ];

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cards
            .map(
              (card) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _ActionCard(
                  title: card.title,
                  icon: card.icon,
                  onTap: card.onTap,
                ),
              ),
            )
            .toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cards
            .asMap()
            .entries
            .map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  right: entry.key < cards.length - 1 ? AppSpacing.xl : 0,
                ),
                child: _ActionCard(
                  title: entry.value.title,
                  icon: entry.value.icon,
                  onTap: entry.value.onTap,
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
          style: AppText.formTitle.copyWith(fontSize: isMobile ? 20 : 24),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildStatCards(isCompact),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NGO Pending Requests', style: AppText.formTitle),
        const SizedBox(height: AppSpacing.lg),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xxl),
              child: CircularProgressIndicator(color: AppColors.primaryMaroon),
            ),
          )
        else if (_ngoRequests.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: SimpleDecoration.card(),
            child: Center(
              child: Text('No pending requests', style: AppText.subtitle),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ngoRequests.length,
            itemBuilder: (context, index) {
              final ngo = _ngoRequests[index];
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
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: logoUrl.startsWith('http')
                            ? Image.network(
                                logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.business,
                                    color: AppColors.primaryMaroon,
                                    size: 24,
                                  );
                                },
                              )
                            : Image.asset(
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
                    Expanded(child: Text(ngoName, style: AppText.fieldLabel)),
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
                            onTap: () => _showNgoDetails(builderContext, ngo),
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
  }

  Widget _buildStatCards(bool isCompact) {
    const stats = [
      _StatCardData(
        title: 'Active Users',
        value: '1,452',
        percentage: '+5.2%',
        isPositive: true,
      ),
      _StatCardData(
        title: 'Registered NGOs',
        value: '87',
        percentage: '+1.5%',
        isPositive: true,
      ),
      _StatCardData(
        title: 'Ongoing Operations',
        value: '12',
        percentage: '-3.0%',
        isPositive: false,
      ),
    ];

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: stats
            .map(
              (stat) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _StatCard(
                  title: stat.title,
                  value: stat.value,
                  percentage: stat.percentage,
                  percentageColor: stat.isPositive
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
                    title: entry.value.title,
                    value: entry.value.value,
                    percentage: entry.value.percentage,
                    percentageColor: entry.value.isPositive
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

// Data Classes
class _ActionCardData {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCardData({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class _StatCardData {
  final String title;
  final String value;
  final String percentage;
  final bool isPositive;

  const _StatCardData({
    required this.title,
    required this.value,
    required this.percentage,
    required this.isPositive,
  });
}

// Extracted Widgets
class _NavBarContainer extends StatelessWidget {
  final bool isMobile;
  const _NavBarContainer({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SimpleDecoration.container(),
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
