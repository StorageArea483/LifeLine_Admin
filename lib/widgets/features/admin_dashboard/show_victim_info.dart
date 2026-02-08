import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:life_line_admin/services/functions/transitions_in_pages.dart';
import 'package:life_line_admin/utils/styles.dart';
import 'package:life_line_admin/widgets/constants/constants.dart';
import 'package:life_line_admin/services/functions/nav_bar.dart';
import 'package:life_line_admin/widgets/features/admin_dashboard/admin_dasboard.dart';

class ShowVictimInfo extends StatefulWidget {
  const ShowVictimInfo({super.key});

  @override
  State<ShowVictimInfo> createState() => _ShowVictimInfoState();
}

class _ShowVictimInfoState extends State<ShowVictimInfo> {
  final TextEditingController _searchController = TextEditingController();
  FirebaseFirestore? _victimFirestore;
  bool _isLoading = false;
  List<Map<String, dynamic>> _victims = [];

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
  void initState() {
    super.initState();
    _initVictimFirebase();
  }

  Future<void> _initVictimFirebase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final victimApp = await Firebase.initializeApp(
        name: 'life-line-victim',
        options: _victimFirebaseOptions,
      );
      _victimFirestore = FirebaseFirestore.instanceFor(app: victimApp);
      await _searchVictims();
    } catch (e) {
      debugPrint('Error initializing victim Firebase: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchVictims() async {
    if (_victimFirestore == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await _victimFirestore!
          .collection('victim-info-database')
          .get();

      if (mounted) {
        final allVictims = querySnapshot.docs.map((doc) => doc.data()).toList();
        final searchTerm = _searchController.text;

        if (searchTerm.isEmpty) {
          setState(() {
            _victims = allVictims;
            _isLoading = false;
          });
          return;
        }

        var filteredVictims = allVictims.where((victim) {
          final firstName = (victim['firstName'] ?? '').toString();
          return firstName.contains(searchTerm);
        }).toList();

        if (filteredVictims.isEmpty) {
          filteredVictims = allVictims.where((victim) {
            final firstName = (victim['firstName'] ?? '').toString();
            final lastName = (victim['lastName'] ?? '').toString();
            final fullName = '$firstName $lastName';
            return fullName.contains(searchTerm);
          }).toList();
        }

        setState(() {
          _victims = filteredVictims;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeUser(String phoneNumber) async {
    if (_victimFirestore == null) return;

    try {
      final querySnapshot = await _victimFirestore!
          .collection('victim-info-database')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _searchVictims();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing user: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _blockUser(String phoneNumber) async {
    if (_victimFirestore == null) return;

    try {
      final querySnapshot = await _victimFirestore!
          .collection('victim-info-database')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'blocked': true});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User blocked successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _searchVictims();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error blocking user: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unblockUser(String phoneNumber) async {
    if (_victimFirestore == null) return;

    try {
      final querySnapshot = await _victimFirestore!
          .collection('victim-info-database')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'blocked': false});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User unblocked successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _searchVictims();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error blocking user: ${e.toString()}'),
            backgroundColor: Colors.red,
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
      'Victim List',
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
      onPressed: _isLoading ? null : _searchVictims,
      style: AppButtons.submit,
      child: _isLoading ? const _LoadingIndicator() : const Text('Search'),
    );
  }

  Widget _buildContent(bool isMobile, bool isTablet) {
    if (_isLoading) {
      return const _CenteredLoader();
    }

    if (_victims.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxxl),
          child: Text('No record found', style: AppText.subtitle),
        ),
      );
    }

    return isMobile || isTablet
        ? _buildMobileVictimList()
        : _buildWebVictimTable();
  }

  Widget _buildWebVictimTable() {
    return Container(
      decoration: SimpleDecoration.table(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Table(
        border: TableBorder.all(color: AppColors.softBackground),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(1),
          4: FlexColumnWidth(1),
          5: FlexColumnWidth(1),
        },
        children: [
          _TableHeader(),
          ..._victims.map((victim) => _buildTableRow(victim)),
        ],
      ),
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> victim) {
    final firstName = victim['firstName'] ?? '';
    final lastName = victim['lastName'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final phoneNumber = victim['phoneNumber'] ?? 'N/A';
    final location = victim['Location'] ?? 'N/A';
    final isBlocked = victim['blocked'] ?? false;

    final textStyle = TextStyle(
      decoration: isBlocked ? TextDecoration.lineThrough : TextDecoration.none,
    );

    return TableRow(
      children: [
        _TableCell(text: fullName.isEmpty ? 'N/A' : fullName, style: textStyle),
        _TableCell(
          text: phoneNumber.isEmpty ? 'N/A' : phoneNumber,
          style: textStyle,
        ),
        _TableCell(text: location.isEmpty ? 'N/A' : location, style: textStyle),
        _ActionCell(
          icon: Icons.delete,
          onPressed: () {
            if (phoneNumber != 'N/A') _removeUser(phoneNumber);
          },
        ),
        _ActionCell(
          icon: Icons.block,
          onPressed: () {
            if (phoneNumber != 'N/A') _blockUser(phoneNumber);
          },
        ),
        _ActionCell(
          icon: Icons.lock_open,
          onPressed: () {
            if (phoneNumber != 'N/A') _unblockUser(phoneNumber);
          },
        ),
      ],
    );
  }

  Widget _buildMobileVictimList() {
    return Column(
      children: _victims.map((victim) => _buildMobileCard(victim)).toList(),
    );
  }

  Widget _buildMobileCard(Map<String, dynamic> victim) {
    final firstName = victim['firstName'] ?? '';
    final lastName = victim['lastName'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final phoneNumber = victim['phoneNumber'] ?? 'N/A';
    final location = victim['Location'] ?? 'N/A';
    final isBlocked = victim['blocked'] ?? false;

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
            fullName.isEmpty ? 'N/A' : fullName,
            style: AppText.fieldLabel.copyWith(
              fontSize: 18,
              decoration: textDecoration,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.phone,
            text: phoneNumber,
            decoration: textDecoration,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.location_on,
            text: location,
            decoration: textDecoration,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActionButtons(phoneNumber),
        ],
      ),
    );
  }

  Widget _buildActionButtons(String phoneNumber) {
    return Row(
      children: [
        Expanded(
          child: _MobileActionButton(
            icon: Icons.delete,
            label: 'Remove',
            color: AppColors.error,
            onPressed: () {
              if (phoneNumber != 'N/A') _removeUser(phoneNumber);
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
              if (phoneNumber != 'N/A') _blockUser(phoneNumber);
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MobileActionButton(
            icon: Icons.lock_open,
            label: 'Unblock',
            color: AppColors.success,
            onPressed: () {
              if (phoneNumber != 'N/A') _unblockUser(phoneNumber);
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
          _HeaderCell(text: 'Contact Information'),
          _HeaderCell(text: 'Location'),
          _HeaderCell(text: 'Remove User'),
          _HeaderCell(text: 'Block User'),
          _HeaderCell(text: 'Unblock User'),
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
