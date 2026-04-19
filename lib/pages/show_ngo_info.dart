import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_line_admin/providers/ngo_info_provider.dart';
import 'package:life_line_admin/styles/styles.dart';
import 'package:life_line_admin/widgets/global/loading_indicator.dart';
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

  static const FirebaseOptions _ngoFirebaseOptions = FirebaseOptions(
    apiKey: 'AIzaSyBeieryGaw4bh4dtbrI54qsIc51XkP6SoM',
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      await _fetchNgos();
    } catch (e) {
      if (mounted) {
        ref.read(ngoPageProvider.notifier).setLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred please refresh page'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _fetchNgos() async {
    if (_ngoFirestore == null) return;

    try {
      final snapshot = await _ngoFirestore!
          .collection('ngo-info-database')
          .get();

      if (mounted) {
        ref.read(ngoPageProvider.notifier).setLoading(false);
        if (snapshot.docs.isNotEmpty) {
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final isApproved = data['approved'] ?? false;

            if (isApproved && mounted) {
              final ngoData = {
                'docId': doc.id,
                'name': data['ngoName'] ?? 'Unknown NGO',
                'branchName': data['branchName'] ?? 'N/A',
                'geographicalCoverage': data['geographicalCoverage'] ?? 'N/A',
                'registrationNumber': data['registrationNumber'] ?? 'N/A',
                'status': 'Approved',
              };
              ref.read(ngoPageProvider.notifier).addNgo(ngoData);
              ref.read(ngoPageProvider.notifier).addAllNgos(ngoData);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ref.read(ngoPageProvider.notifier).setLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error fetching NGO data please refresh page'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _removeNgo(String docId) async {
    if (_ngoFirestore == null) return;

    try {
      await _ngoFirestore!.collection('ngo-info-database').doc(docId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NGO removed successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        ref
            .read(ngoPageProvider)
            .ngos
            .removeWhere((ngo) => ngo['docId'] == docId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occured please try again'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _blockNgo(String docId) {
    if (mounted) {
      ref.read(ngoPageProvider).blockedNgos.add(docId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NGO blocked successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _searchNgos() async {
    if (mounted) {
      ref.read(ngoPageProvider.notifier).setIsSearching(true);
    }
    if (mounted) {
      final searchTerm = _searchController.text.toLowerCase();

      if (searchTerm.isEmpty && mounted) {
        ref.read(ngoPageProvider).ngos.clear();
        ref
            .read(ngoPageProvider)
            .ngos
            .addAll(ref.read(ngoPageProvider).allNgos);
        ref.read(ngoPageProvider.notifier).setIsSearching(false);
        return;
      }
      if (!mounted) return;
      final filteredNgos = ref.read(ngoPageProvider).allNgos.where((ngo) {
        final name = (ngo['name'] ?? '').toString().toLowerCase();
        return name.contains(searchTerm);
      }).toList();

      if (mounted) {
        ref.read(ngoPageProvider).ngos.clear();
        ref.read(ngoPageProvider).ngos.addAll(filteredNgos);
        ref.read(ngoPageProvider.notifier).setIsSearching(false);
      }
    }
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
                  decoration: SimpleDecoration.container(),
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
                        Text(
                          'NGO List',
                          style: AppText.formTitle.copyWith(
                            fontSize: isMobile ? 20 : 24,
                          ),
                        ),
                        SizedBox(
                          height: isMobile ? AppSpacing.lg : AppSpacing.xxl,
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              if (mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminDashboard(),
                                  ),
                                );
                              }
                            },
                            child: const Icon(Icons.arrow_back),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
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
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name...',
              hintStyle: AppText.textFieldHint,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDecorations.textFieldRadius,
                ),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: Consumer(
              builder: (context, ref, child) {
                if (!mounted) return const SizedBox.shrink();
                final isSearching = ref.watch(
                  ngoPageProvider.select((v) => v.isSearching),
                );
                return ElevatedButton(
                  onPressed: isSearching ? null : _searchNgos,
                  style: AppButtons.submit,
                  child: isSearching
                      ? const LoadingIndicator()
                      : const Text('Search'),
                );
              },
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by name...',
              hintStyle: AppText.textFieldHint,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppDecorations.textFieldRadius,
                ),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Consumer(
          builder: (context, ref, child) {
            if (!mounted) return const SizedBox.shrink();
            final isSearching = ref.watch(
              ngoPageProvider.select((v) => v.isSearching),
            );
            return ElevatedButton(
              onPressed: isSearching ? null : _searchNgos,
              style: AppButtons.submit,
              child: isSearching
                  ? const LoadingIndicator()
                  : const Text('Search'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContent(bool isMobile, bool isTablet, WidgetRef ref) {
    if (!mounted) return const SizedBox.shrink();
    final isLoading = ref.watch(ngoPageProvider.select((v) => v.isLoading));
    if (!mounted) return const SizedBox.shrink();
    final ngos = ref.watch(ngoPageProvider.select((v) => v.ngos));
    if (isLoading) {
      return const LoadingIndicator();
    }
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
                'No NGO data found',
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
      decoration: SimpleDecoration.table(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Consumer(
        builder: (context, ref, child) {
          if (!mounted) return const SizedBox.shrink();
          final ngos = ref.watch(ngoPageProvider.select((v) => v.ngos));
          return Table(
            border: TableBorder.all(color: AppColors.softBackground),
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
              4: FlexColumnWidth(2),
              5: FlexColumnWidth(1),
              6: FlexColumnWidth(1),
            },
            children: [
              _TableHeader(),
              ...ngos.map((ngo) => (_buildTableRow(ngo, ref))),
            ],
          );
        },
      ),
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> ngo, WidgetRef ref) {
    final name = ngo['name'] ?? 'Unknown NGO';
    final branchName = ngo['branchName'] ?? 'N/A';
    final geographicalCoverage = ngo['geographicalCoverage'] ?? 'N/A';
    final registrationNumber = ngo['registrationNumber'] ?? 'N/A';
    final status = ngo['status'] ?? 'N/A';
    final docId = ngo['docId'] ?? '';
    if (!mounted) return const TableRow(children: []);
    final isBlocked = ref.watch(ngoPageProvider).blockedNgos.contains(docId);

    final textStyle = TextStyle(
      decoration: isBlocked ? TextDecoration.lineThrough : TextDecoration.none,
    );

    return TableRow(
      children: [
        _TableCell(text: name, style: textStyle),
        _TableCell(text: branchName, style: textStyle),
        _TableCell(text: geographicalCoverage, style: textStyle),
        _TableCell(text: registrationNumber, style: textStyle),
        _TableCell(text: status, style: textStyle),
        _ActionCell(
          icon: Icons.delete,
          onPressed: () {
            if (docId.isNotEmpty) _removeNgo(docId);
          },
        ),
        _ActionCell(
          icon: Icons.block,
          onPressed: () {
            if (docId.isNotEmpty) _blockNgo(docId);
          },
        ),
      ],
    );
  }

  Widget _buildMobileNgoList(WidgetRef ref) {
    if (!mounted) return const SizedBox.shrink();
    final ngos = ref.watch(ngoPageProvider.select((v) => v.ngos));
    return Column(
      children: ngos.map((ngo) => _buildMobileCard(ngo, ref)).toList(),
    );
  }

  Widget _buildMobileCard(Map<String, dynamic> ngo, WidgetRef ref) {
    final name = ngo['name'] ?? 'Unknown NGO';
    final branchName = ngo['branchName'] ?? 'N/A';
    final geographicalCoverage = ngo['geographicalCoverage'] ?? 'N/A';
    final registrationNumber = ngo['registrationNumber'] ?? 'N/A';
    final status = ngo['status'] ?? 'N/A';
    final docId = ngo['docId'] ?? '';
    if (!mounted) return const SizedBox.shrink();
    final isBlocked = ref.watch(ngoPageProvider).blockedNgos.contains(docId);

    final textDecoration = isBlocked
        ? TextDecoration.lineThrough
        : TextDecoration.none;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: SimpleDecoration.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppText.fieldLabel.copyWith(
              fontSize: 18,
              decoration: textDecoration,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoRow(
            icon: Icons.business_center,
            text: 'Branch: $branchName',
            decoration: textDecoration,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.location_on,
            text: 'Coverage: $geographicalCoverage',
            decoration: textDecoration,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.numbers,
            text: 'Reg #: $registrationNumber',
            decoration: textDecoration,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.check_circle,
            text: 'Status: $status',
            decoration: textDecoration,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActionButtons(docId),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String docId) {
    return Row(
      children: [
        Expanded(
          child: _MobileActionButton(
            icon: Icons.delete,
            label: 'Remove',
            color: AppColors.error,
            onPressed: () {
              if (docId.isNotEmpty) _removeNgo(docId);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MobileActionButton(
            icon: Icons.block,
            label: 'Block',
            color: AppColors.warning,
            onPressed: () {
              if (docId.isNotEmpty) _blockNgo(docId);
            },
          ),
        ),
      ],
    );
  }
}

class _TableHeader extends TableRow {
  _TableHeader()
    : super(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryMaroon.withValues(alpha: 0.15),
              AppColors.accentRose.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        children: const [
          _HeaderCell(text: 'Name'),
          _HeaderCell(text: 'Branch Name'),
          _HeaderCell(text: 'Geographical Coverage'),
          _HeaderCell(text: 'Registration Number'),
          _HeaderCell(text: 'Status'),
          _HeaderCell(text: 'Remove NGO'),
          _HeaderCell(text: 'Block NGO'),
        ],
      );
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(text, style: AppText.fieldLabel),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const _TableCell({required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(text, style: style),
    );
  }
}

class _ActionCell extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _ActionCell({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primaryMaroon),
        onPressed: onPressed,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final TextDecoration decoration;
  const _InfoRow({
    required this.icon,
    required this.text,
    required this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppText.base.copyWith(
              color: AppColors.textSecondary,
              decoration: decoration,
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _MobileActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
