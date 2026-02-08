import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:life_line_admin/services/functions/transitions_in_pages.dart';
import 'package:life_line_admin/utils/styles.dart';
import 'package:life_line_admin/widgets/constants/constants.dart';
import 'package:life_line_admin/services/functions/nav_bar.dart';
import 'package:life_line_admin/widgets/features/admin_dashboard/admin_dasboard.dart';

class ShowNgoInfo extends StatefulWidget {
  const ShowNgoInfo({super.key});

  @override
  State<ShowNgoInfo> createState() => _ShowNgoInfoState();
}

class _ShowNgoInfoState extends State<ShowNgoInfo> {
  bool _isLoading = false;
  bool _isSearching = false;
  final List<Map<String, dynamic>> _ngos = [];
  final List<Map<String, dynamic>> _allNgos = [];
  final Set<String> _blockedNgos = {};
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
    _initSecondaryFirebase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initSecondaryFirebase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final secondaryApp = await Firebase.initializeApp(
        name: 'life-line-ngo-show',
        options: _ngoFirebaseOptions,
      );
      _ngoFirestore = FirebaseFirestore.instanceFor(app: secondaryApp);
      await _fetchNgos();
    } catch (e) {
      debugPrint('Error initializing secondary Firebase: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchNgos() async {
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

            if (isApproved) {
              final ngoData = {
                'docId': doc.id,
                'name': data['ngoName'] ?? 'Unknown NGO',
                'branchName': data['branchName'] ?? 'N/A',
                'geographicalCoverage': data['geographicalCoverage'] ?? 'N/A',
                'registrationNumber': data['registrationNumber'] ?? 'N/A',
                'status': 'Approved',
              };
              _allNgos.add(ngoData);
              _ngos.add(ngoData);
            }
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

  Future<void> _removeNgo(String docId) async {
    if (_ngoFirestore == null) return;

    try {
      await _ngoFirestore!.collection('ngo-info-database').doc(docId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('NGO removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _ngos.removeWhere((ngo) => ngo['docId'] == docId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing NGO: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _blockNgo(String docId) {
    setState(() {
      _blockedNgos.add(docId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('NGO blocked successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _searchNgos() async {
    setState(() {
      _isSearching = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      final searchTerm = _searchController.text.toLowerCase();

      if (searchTerm.isEmpty) {
        setState(() {
          _ngos.clear();
          _ngos.addAll(_allNgos);
          _isSearching = false;
        });
        return;
      }

      final filteredNgos = _allNgos.where((ngo) {
        final name = (ngo['name'] ?? '').toString().toLowerCase();
        return name.contains(searchTerm);
      }).toList();

      setState(() {
        _ngos.clear();
        _ngos.addAll(filteredNgos);
        _isSearching = false;
      });
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
                _buildNavBar(isMobile),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      isMobile ? AppSpacing.lg : AppSpacing.xxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(isMobile),
                        SizedBox(
                          height: isMobile ? AppSpacing.lg : AppSpacing.xxl,
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () =>
                                pageTransition(context, const AdminDashboard()),
                            child: const Icon(Icons.arrow_back),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSearchBar(isMobile),
                        SizedBox(
                          height: isMobile ? AppSpacing.lg : AppSpacing.xxl,
                        ),
                        _buildContent(isMobile, isTablet),
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

  Widget _buildNavBar(bool isMobile) {
    return Container(
      decoration: SimpleDecoration.container(),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.lg : AppSpacing.xxl,
        vertical: isMobile ? AppSpacing.md : AppSpacing.lg,
      ),
      child: const NavBar(),
    );
  }

  Widget _buildTitle(bool isMobile) {
    return Text(
      'NGO List',
      style: AppText.formTitle.copyWith(fontSize: isMobile ? 20 : 24),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: AppSpacing.md),
          SizedBox(width: double.infinity, child: _buildSearchButton()),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildSearchField()),
        const SizedBox(width: AppSpacing.lg),
        _buildSearchButton(),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search by name...',
        hintStyle: AppText.textFieldHint,
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDecorations.textFieldRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: _isSearching ? null : _searchNgos,
      style: AppButtons.submit,
      child: _isSearching ? const _LoadingIndicator() : const Text('Search'),
    );
  }

  Widget _buildContent(bool isMobile, bool isTablet) {
    if (_isLoading) {
      return const _CenteredLoader();
    }

    if (_ngos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxxl),
          child: Text('No NGO data found', style: AppText.subtitle),
        ),
      );
    }

    return isMobile || isTablet ? _buildMobileNgoList() : _buildWebNgoTable();
  }

  Widget _buildWebNgoTable() {
    return Container(
      decoration: SimpleDecoration.table(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Table(
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
        children: [_TableHeader(), ..._ngos.map((ngo) => _buildTableRow(ngo))],
      ),
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> ngo) {
    final name = ngo['name'] ?? 'Unknown NGO';
    final branchName = ngo['branchName'] ?? 'N/A';
    final geographicalCoverage = ngo['geographicalCoverage'] ?? 'N/A';
    final registrationNumber = ngo['registrationNumber'] ?? 'N/A';
    final status = ngo['status'] ?? 'N/A';
    final docId = ngo['docId'] ?? '';
    final isBlocked = _blockedNgos.contains(docId);

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

  Widget _buildMobileNgoList() {
    return Column(children: _ngos.map((ngo) => _buildMobileCard(ngo)).toList());
  }

  Widget _buildMobileCard(Map<String, dynamic> ngo) {
    final name = ngo['name'] ?? 'Unknown NGO';
    final branchName = ngo['branchName'] ?? 'N/A';
    final geographicalCoverage = ngo['geographicalCoverage'] ?? 'N/A';
    final registrationNumber = ngo['registrationNumber'] ?? 'N/A';
    final status = ngo['status'] ?? 'N/A';
    final docId = ngo['docId'] ?? '';
    final isBlocked = _blockedNgos.contains(docId);

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

// Const Widgets
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

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxxl),
        child: CircularProgressIndicator(color: AppColors.primaryMaroon),
      ),
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
