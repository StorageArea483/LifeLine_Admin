import 'package:flutter/material.dart';
import 'package:life_line_admin/services/functions/transitions_in_pages.dart';
import 'package:life_line_admin/utils/styles.dart';
import 'package:life_line_admin/widgets/constants/constants.dart';
import 'package:life_line_admin/widgets/features/admin_dashboard/admin_dasboard.dart';
import 'package:life_line_admin/widgets/global/admin_authentication.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryMaroon,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('LifeLine', style: AppText.appHeader),
          ],
        ),

        // Navigation Menu
        isMobile || isTablet
            ? Builder(
                builder: (BuildContext scaffoldContext) {
                  return IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.darkCharcoal),
                    onPressed: () {
                      Scaffold.of(scaffoldContext).openDrawer();
                    },
                  );
                },
              )
            : Row(
                children: [
                  _buildNavItem(title: 'Dashboard'),
                  const SizedBox(width: AppSpacing.xxl),
                  _buildNavItem(title: 'Reports'),
                  const SizedBox(width: AppSpacing.xxl),
                  _buildNavItem(title: 'Settings'),
                  const SizedBox(width: AppSpacing.xxl),
                  ElevatedButton(
                    onPressed: () {
                      pageTransition(context, const AdminAuthentication());
                    },
                    style: AppButtons.submit.copyWith(
                      minimumSize: WidgetStateProperty.all(const Size(80, 36)),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildNavItem({required String title, VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: AppText.base.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

Widget buildDrawer(BuildContext context) {
  return Drawer(
    child: Container(
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryMaroon),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: AppColors.primaryMaroon,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'LifeLine Admin',
                  style: AppText.formTitle.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.dashboard,
              color: AppColors.primaryMaroon,
            ),
            title: Text('Dashboard', style: AppText.fieldLabel),
            onTap: () {
              pageTransition(context, const AdminDashboard());
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.assessment,
              color: AppColors.primaryMaroon,
            ),
            title: Text('Reports', style: AppText.fieldLabel),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.primaryMaroon),
            title: Text('Settings', style: AppText.fieldLabel),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  pageTransition(context, const AdminAuthentication());
                },
                style: AppButtons.submit,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
