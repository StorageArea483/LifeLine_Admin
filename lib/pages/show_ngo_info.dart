import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_admin/providers/ngo_info_provider.dart';
import 'package:life_line_admin/styles/styles.dart';
import 'package:life_line_admin/widgets/nav_bar.dart';
import 'package:life_line_admin/pages/admin_dasboard.dart';

class ShowNgoInfo extends ConsumerStatefulWidget {
  const ShowNgoInfo({super.key});

  @override
  ConsumerState<ShowNgoInfo> createState() => _ShowNgoInfoState();
}

class _ShowNgoInfoState extends ConsumerState<ShowNgoInfo> {
  final TextEditingController _searchController = TextEditingController();
  FirebaseFirestore? _ngoFirestore;
  StreamSubscription? ngoSubscription;

  static const FirebaseOptions _ngoFirebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyBeieryGaw4bh4dtbrI54qsIc51XkP6SoM',
    appId: '1:169949190544:web:2640453ce5dd2aa55d3b15',
    messagingSenderId: '169949190544',
    projectId: 'life-line-ngo',
    authDomain: 'life-line-ngo.firebaseapp.com',
    storageBucket: 'life-line-ngo.firebasestorage.app',
  );

  @override
  void dispose() {
    _searchController.dispose();
    ngoSubscription?.cancel();
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
      ref.read(ngoPageProvider.notifier).setLoading(true);
    }

    try {
      final secondaryApp = await Firebase.initializeApp(
        name: 'life-line-ngo',
        options: _ngoFirebaseOptions,
      );
      _ngoFirestore = FirebaseFirestore.instanceFor(app: secondaryApp);
      _listenToNgos();
    } catch (e) {
      if (mounted) {
        ref.read(ngoPageProvider.notifier).setLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _listenToNgos() {
    if (_ngoFirestore == null) return;

    if (mounted) {
      ref.read(ngoPageProvider.notifier).setLoading(true);
    }

    ngoSubscription = _ngoFirestore!
        .collection('ngo-info-database')
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;

          final allNgos = snapshot.docs.map((doc) => doc.data()).toList();

          final searchTerm = _searchController.text;

          List<Map<String, dynamic>> finalList;

          if (searchTerm.isEmpty) {
            finalList = allNgos;
          } else {
            finalList = allNgos.where((ngo) {
              final name = (ngo['ngoName'] ?? '').toString();
              return name.toLowerCase().contains(searchTerm.toLowerCase());
            }).toList();
          }
          if (mounted) {
            ref.read(ngoPageProvider.notifier).setNgos(finalList);
            ref.read(ngoPageProvider.notifier).setLoading(false);
          }
        });
  }

  Future<void> _removeNgo(String regNumber) async {
    if (_ngoFirestore == null) return;

    if (mounted) {
      ref.read(ngoPageProvider.notifier).setLoading(true);
    }

    try {
      final querySnapshot = await _ngoFirestore!
          .collection('ngo-info-database')
          .where('registrationNumber', isEqualTo: regNumber)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error removing user, please try again'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _blockNgo(String regNumber) async {
    if (_ngoFirestore == null) return;

    if (mounted) {
      ref.read(ngoPageProvider.notifier).setLoading(true);
    }

    try {
      final querySnapshot = await _ngoFirestore!
          .collection('ngo-info-database')
          .where('registrationNumber', isEqualTo: regNumber)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'blocked': true});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error blocking NGO, please retry'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _unblockNgo(String regNumber) async {
    if (_ngoFirestore == null) return;

    if (mounted) {
      ref.read(ngoPageProvider.notifier).setLoading(true);
    }

    try {
      final querySnapshot = await _ngoFirestore!
          .collection('ngo-info-database')
          .where('registrationNumber', isEqualTo: regNumber)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'blocked': false});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error blocking NGO, please retry'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
                            _buildSearchBar(isMobile),
                            SizedBox(
                              height: isMobile ? AppSpacing.lg : AppSpacing.xxl,
                            ),
                            Consumer(
                              builder: (context, ref, child) {
                                return _buildContent(isMobile, isTablet, ref);
                              },
                            ),
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
                  ngoPageProvider.select((v) => v.isLoading),
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
                  'NGO Management',
                  style: TextStyle(
                    fontSize: isMobile ? 24 : 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage and monitor registered Ngos',
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

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkCharcoal.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.softBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Ngo name to search...',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: Consumer(
                        builder: (context, ref, child) {
                          if (!mounted) return const SizedBox.shrink();
                          final isLoading = ref.watch(
                            ngoPageProvider.select((v) => v.isLoading),
                          );
                          return ElevatedButton(
                            onPressed: isLoading ? null : _listenToNgos,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryMaroon,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Search Ngos',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.softBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Enter Ngo name to search...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    SizedBox(
                      height: 48,
                      child: Consumer(
                        builder: (context, ref, child) {
                          if (!mounted) return const SizedBox.shrink();
                          final isLoading = ref.watch(
                            ngoPageProvider.select((v) => v.isLoading),
                          );
                          return ElevatedButton(
                            onPressed: isLoading ? null : _listenToNgos,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryMaroon,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Search Ngos',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isMobile, bool isTablet, WidgetRef ref) {
    if (!mounted) return const SizedBox.shrink();
    final ngos = ref.watch(ngoPageProvider.select((v) => v.ngos));

    if (ngos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.search_off_outlined,
                size: 64,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No NGOs data found',
                style: AppText.subtitle.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return isMobile || isTablet
        ? _buildMobileNgoList(ref)
        : _buildWebNgoTable();
  }

  Widget _buildWebNgoTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkCharcoal.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Content using Table widget
          Consumer(
            builder: (context, ref, child) {
              if (!mounted) return const SizedBox.shrink();
              final ngos = ref.watch(ngoPageProvider.select((v) => v.ngos));
              return Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2),
                  4: FlexColumnWidth(1),
                  5: FlexColumnWidth(1.2),
                  6: FlexColumnWidth(1.3),
                },
                children: [
                  // Header Row
                  TableRow(
                    decoration: BoxDecoration(
                      color: AppColors.primaryMaroon.withValues(alpha: 0.03),
                      border: const Border(
                        bottom: BorderSide(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                    ),
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.lg,
                          ),
                          child: Text(
                            'Name',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.formDescription.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.lg,
                          ),
                          child: Text(
                            'Branch Name',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.formDescription.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.lg,
                          ),
                          child: Text(
                            'Geographical Coverage',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.formDescription.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.lg,
                          ),
                          child: Text(
                            'Registration Number',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.formDescription.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.lg,
                          ),
                          child: Text(
                            'Status',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.formDescription.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxxxl,
                            vertical: AppSpacing.lg,
                          ),
                          child: Text(
                            'Actions',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.formDescription.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xxxxl,
                            vertical: AppSpacing.lg,
                          ),
                          child: Text(
                            'Remove NGO',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.formDescription.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Data Rows
                  ...ngos.asMap().entries.map((entry) {
                    final ngo = entry.value;
                    final name = ngo['ngoName'] ?? 'N/A';
                    final branchName = ngo['branchName'] ?? 'N/A';
                    final coverage = ngo['geographicalCoverage'] ?? 'N/A';
                    final regNumber = ngo['registrationNumber'] ?? false;
                    final isBlocked = ngo['blocked'] ?? false;
                    final isApproved = ngo['approved'] ?? false;

                    return TableRow(
                      decoration: BoxDecoration(
                        color: AppColors.softBackground.withValues(alpha: 0.3),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      children: [
                        // Name Cell
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                            ),
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.fieldLabel.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                decoration: isBlocked
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                        // Branch Name Cell
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxl,
                            ),
                            child: Text(
                              branchName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.fieldLabel.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                decoration: isBlocked
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                        // Coverage Cell
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxxxl,
                            ),
                            child: Text(
                              coverage,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.fieldLabel.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                decoration: isBlocked
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                        // Reg Number Cell
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxxxl,
                            ),
                            child: Text(
                              regNumber,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.fieldLabel.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                decoration: isBlocked
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                        // Status Cell
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                            ),
                            child: Text(
                              isApproved ? 'Approved' : 'Not Approved',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.fieldLabel.copyWith(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                decoration: isBlocked
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                        // Actions Cell (Block/Unblock)
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (regNumber != 'N/A') {
                                  isBlocked
                                      ? _unblockNgo(regNumber)
                                      : _blockNgo(regNumber);
                                }
                              },
                              icon: isBlocked
                                  ? const Icon(
                                      Icons.block,
                                      color: AppColors.accentRose,
                                    )
                                  : const Icon(
                                      Icons.lock_open,
                                      color: AppColors.accentRose,
                                    ),
                            ),
                          ),
                        ),
                        // Remove NGO Cell
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xl,
                              vertical: AppSpacing.lg,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                if (regNumber != 'N/A') _removeNgo(regNumber);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: AppColors.accentRose,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNgoList(WidgetRef ref) {
    if (!mounted) return const SizedBox.shrink();
    final ngos = ref.watch(ngoPageProvider.select((v) => v.ngos));
    return Column(children: ngos.map((ngo) => _buildMobileCard(ngo)).toList());
  }

  Widget _buildMobileCard(Map<String, dynamic> ngo) {
    final name = ngo['ngoName'] ?? 'N/A';
    final branchName = ngo['branchName'] ?? 'N/A';
    final coverage = ngo['geographicalCoverage'] ?? 'N/A';
    final regNumber = ngo['registrationNumber'] ?? false;
    final isBlocked = ngo['blocked'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Header Section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkCharcoal,
                decoration: isBlocked
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _MobileInfoRow(
                  label: 'Branch Name',
                  value: branchName,
                  isBlocked: isBlocked,
                ),
                const SizedBox(height: AppSpacing.md),
                _MobileInfoRow(
                  label: 'Coverage',
                  value: coverage,
                  isBlocked: isBlocked,
                ),
                const SizedBox(height: AppSpacing.lg),
                _MobileInfoRow(
                  label: 'Registration Number',
                  value: regNumber,
                  isBlocked: isBlocked,
                ),
                const SizedBox(height: AppSpacing.lg),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: _MobileActionButton(
                        label: 'Remove',
                        color: AppColors.error,
                        onPressed: () {
                          if (regNumber != 'N/A') _removeNgo(regNumber);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      child: _MobileActionButton(
                        label: isBlocked ? 'Unblock' : 'Block',
                        color: isBlocked
                            ? AppColors.success
                            : AppColors.warning,
                        onPressed: () {
                          if (regNumber != 'N/A') {
                            isBlocked
                                ? _unblockNgo(regNumber)
                                : _blockNgo(regNumber);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBlocked;

  const _MobileInfoRow({
    required this.label,
    required this.value,
    required this.isBlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.darkCharcoal,
              decoration: isBlocked
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _MobileActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _MobileActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
