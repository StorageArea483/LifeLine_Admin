import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_admin/pages/admin_authentication.dart';
import 'package:life_line_admin/pages/show_rescuer_info.dart';
import 'package:life_line_admin/providers/admin_page_provider.dart';
import 'package:life_line_admin/styles/styles.dart';
import 'package:life_line_admin/widgets/global/page_message.dart';
import 'package:life_line_admin/widgets/global/page_navigation.dart';
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
  FirebaseFirestore? _victimFirestore;

  static const FirebaseOptions _ngoFirebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyBeieryGaw4bh4dtbrI54qsIc51XkP6SoM',
    appId: '1:169949190544:web:2640453ce5dd2aa55d3b15',
    messagingSenderId: '169949190544',
    projectId: 'life-line-ngo',
    authDomain: 'life-line-ngo.firebaseapp.com',
    storageBucket: 'life-line-ngo.firebasestorage.app',
  );

  // life-line-victim database credentials
  static const FirebaseOptions _victimFirebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyCgdeU_737w9twNR2zt5dzyG5EXK5uKxR0',
    appId: '1:909144850972:web:a9eb7a5cfcec7e437c55d9',
    messagingSenderId: '909144850972',
    projectId: 'life-line-victim-27aaa',
    authDomain: 'life-line-victim-27aaa.firebaseapp.com',
    storageBucket: 'life-line-victim-27aaa.firebasestorage.app',
  );

  @override
  void dispose() {
    super.dispose();
  }

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
      FirebaseApp ngoApp;
      FirebaseApp victimApp;

      // NGO Firebase
      try {
        ngoApp = Firebase.app('life-line-ngo');
      } catch (_) {
        ngoApp = await Firebase.initializeApp(
          name: 'life-line-ngo',
          options: _ngoFirebaseOptions,
        );
      }

      _ngoFirestore = FirebaseFirestore.instanceFor(app: ngoApp);

      // Victim Firebase
      try {
        victimApp = Firebase.app('life-line-victim');
      } catch (_) {
        victimApp = await Firebase.initializeApp(
          name: 'life-line-victim',
          options: _victimFirebaseOptions,
        );
      }

      _victimFirestore = FirebaseFirestore.instanceFor(app: victimApp);

      await Future.wait([
        _fetchNgoRequests(),
        _fetchVictimCount(),
        _fetchNgoCount(),
      ]);

      if (mounted) {
        ref.read(adminPageProvider.notifier).setLoading(false);
      }
    } catch (e) {
      if (mounted) {
        ref.read(adminPageProvider.notifier).setLoading(false);

        pageMessage(
          'An unexpected error occurred please try again.',
          context,
          AppColors.error,
        );

        pageNavigation(const AdminAuthentication(), context);
      }
    }
  }

  Future<void> _fetchNgoRequests() async {
    if (_ngoFirestore == null) return;

    try {
      // Check settings for auto approval
      final settingsSnapshot = await FirebaseFirestore.instance
          .collection('settings')
          .get();

      bool autoApprovedValue = false;

      if (settingsSnapshot.docs.isNotEmpty) {
        final settingsData = settingsSnapshot.docs.first.data();
        autoApprovedValue = settingsData['auto approved'] ?? false;
      }

      // If auto approval is ON, clear pending requests
      if (autoApprovedValue) {
        if (mounted) {
          ref.read(adminPageProvider.notifier).setNgoRequests([]);
        }
        return;
      }

      // If auto approval is OFF, fetch unapproved NGOs
      final snapshot = await _ngoFirestore!
          .collection('ngo-info-database')
          .where('approved', isEqualTo: false)
          .get();

      if (!mounted) return;

      final requests = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
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
          'approved': false,
          'branchName': data['branchName'] ?? '',
        };
      }).toList();

      if (mounted) {
        ref.read(adminPageProvider.notifier).setNgoRequests(requests);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _fetchNgoCount() async {
    if (_ngoFirestore == null) return;

    try {
      final snapshot = await _ngoFirestore!
          .collection('ngo-info-database')
          .get();

      if (!mounted) return;

      final ngoCount = snapshot.docs.length;

      if (mounted) {
        ref.read(adminPageProvider.notifier).setNgoCount(ngoCount);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _fetchVictimCount() async {
    if (_victimFirestore == null) return;

    try {
      final snapshot = await _victimFirestore!.collection('users').get();

      if (!mounted) return;

      final victimCount = snapshot.docs.length;

      if (mounted) {
        ref.read(adminPageProvider.notifier).setVictimCount(victimCount);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshData() async {
    if (mounted) {
      ref.read(adminPageProvider.notifier).setLoading(true);
    }

    try {
      await _fetchNgoRequests();
      await _fetchVictimCount();
      await _fetchNgoCount();
    } catch (e) {
      if (mounted) {
        pageMessage('Error refreshing data', context, AppColors.error);
      }
    } finally {
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
      if (mounted) {
        ref.read(adminPageProvider.notifier).setLoading(true);
      }
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
        if (context.mounted) {
          Navigator.of(context).pop();
          pageMessage(
            isApproved
                ? 'NGO approved successfully'
                : 'NGO disapproved and removed successfully',
            context,
            isApproved ? AppColors.success : AppColors.error,
          );
          // Refresh data after action
          await refreshData();
        }
      }
    } catch (e) {
      if (context.mounted) {
        pageMessage(
          'An error occurred. Please try again.',
          context,
          AppColors.error,
        );
      }
    } finally {
      if (mounted) {
        ref.read(adminPageProvider.notifier).setLoading(false);
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
                              pageMessage(
                                'Error downloading document. Please try again.',
                                context,
                                AppColors.error,
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildActionButtons(
                                    context,
                                    isCompact,
                                  ),
                                ),
                                if (!isCompact) ...[
                                  const SizedBox(width: AppSpacing.lg),
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: refreshData,
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                          AppSpacing.md,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryMaroon,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.refresh,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (isCompact) ...[
                              const SizedBox(height: AppSpacing.lg),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: refreshData,
                                  icon: const Icon(Icons.refresh, size: 20),
                                  label: const Text('Refresh Data'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryMaroon,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.md,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
            Consumer(
              builder: (context, ref, child) {
                final isLoading = ref.watch(
                  adminPageProvider.select((v) => v.isLoading),
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

  Widget _buildActionButtons(BuildContext context, bool isCompact) {
    final actionButtons = [
      {
        'title': 'View Users',
        'icon': Icons.people_outline,
        'onTap': () {
          pageNavigation(const ShowVictimInfo(), context);
        },
      },
      {
        'title': 'View NGOs',
        'icon': Icons.business_outlined,
        'onTap': () {
          pageNavigation(const ShowNgoInfo(), context);
        },
      },
      {
        'title': 'View Rescuers',
        'icon': Icons.volunteer_activism_outlined,
        'onTap': () {
          pageNavigation(const ShowRescuerInfo(), context);
        },
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
            if (ngoRequests.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: SimpleDecoration.card(),
                child: const Center(
                  child: Text('No pending requests', style: AppText.subtitle),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 600;
                  final isTablet =
                      constraints.maxWidth >= 600 &&
                      constraints.maxWidth < 1024;
                  final isCompact = isMobile || isTablet;

                  return ListView.builder(
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
                        child: isCompact
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppColors.borderLight,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.asset(
                                            logoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.business,
                                                    color:
                                                        AppColors.primaryMaroon,
                                                    size: 24,
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.lg),
                                      Expanded(
                                        child: Text(
                                          ngoName,
                                          style: AppText.fieldLabel,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.warning.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'Pending',
                                          style: AppText.small.copyWith(
                                            color: AppColors.warning,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Builder(
                                        builder: (builderContext) {
                                          return MouseRegion(
                                            cursor: SystemMouseCursors.click,
                                            child: GestureDetector(
                                              onTap: () => _showNgoDetails(
                                                builderContext,
                                                ngo,
                                              ),
                                              child: const Icon(
                                                Icons.read_more,
                                                color: AppColors.warning,
                                                size: 32,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Row(
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
                                        errorBuilder:
                                            (context, error, stackTrace) {
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
                                    child: Text(
                                      ngoName,
                                      style: AppText.fieldLabel,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withValues(
                                        alpha: 0.1,
                                      ),
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
                                  const SizedBox(width: AppSpacing.sm),
                                  Builder(
                                    builder: (builderContext) {
                                      return MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                          onTap: () => _showNgoDetails(
                                            builderContext,
                                            ngo,
                                          ),
                                          child: const Icon(
                                            Icons.read_more,
                                            color: AppColors.warning,
                                            size: 32,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                      );
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatCards(bool isCompact) {
    return Consumer(
      builder: (context, ref, child) {
        if (!mounted) return const SizedBox.shrink();
        final victimCount = ref.watch(
          adminPageProvider.select((v) => v.victimCount),
        );
        if (!mounted) return const SizedBox.shrink();
        final ngoCount = ref.watch(adminPageProvider.select((v) => v.ngoCount));

        final stats = [
          {
            'title': 'Active Users',
            'value': victimCount.toString(),
            'subtitle': 'Real-time count',
            'color': Colors.orange,
          },
          {
            'title': 'Registered NGOs',
            'value': ngoCount.toString(),
            'subtitle': 'Real-time count',
            'color': Colors.purple,
          },
          {
            'title': 'Ongoing Operations',
            'value': '1',
            'subtitle': 'Real-time count',
            'color': Colors.red,
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
                      subtitle: stat['subtitle'] as String,
                      color: stat['color'] as Color,
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
                        subtitle: entry.value['subtitle'] as String,
                        color: entry.value['color'] as Color,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
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
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.fieldLabel.copyWith(
                    color: AppColors.darkCharcoal,
                  ),
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
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkCharcoal.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: color, size: 24),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  title,
                  style: AppText.fieldLabel.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
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
            subtitle,
            style: AppText.small.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
