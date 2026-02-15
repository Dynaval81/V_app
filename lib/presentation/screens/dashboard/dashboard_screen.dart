import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';
import 'package:vtalk_app/core/controllers/tab_visibility_controller.dart';

/// HAI3 Dashboard: App info, Donations, Version, AI/VPN toggles (Airy).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (mounted) context.go(AppRoutes.auth);
  }

  @override
  Widget build(BuildContext context) {
    final tabVisibility = context.watch<TabVisibilityController>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline_rounded, color: AppColors.onSurface),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _SectionCard(
                    title: 'App info',
                    children: [
                      _InfoRow(label: 'App', value: AppConstants.appName),
                      _InfoRow(label: 'Version', value: '${AppConstants.appVersion} (${AppConstants.appBuildNumber})'),
                    ],
                  ),
                  SizedBox(height: 16),
                  _SectionCard(
                    title: 'Donations',
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Support the project – donations help keep V-Talk free and open.',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 16,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _SectionCard(
                    title: 'Version',
                    children: [
                      _InfoRow(label: 'Build', value: AppConstants.appBuildNumber),
                      _InfoRow(label: 'API', value: AppConstants.apiVersion),
                    ],
                  ),
                  SizedBox(height: 16),
                  _SectionCard(
                    title: 'Account',
                    children: [
                      ElevatedButton(
                        onPressed: _logout,
                        child: Text('Log Out'),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  // Elements Store Section
                  ExpansionTile(
                    title: Text(
                      'Элементы',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.all(20),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    children: [
                      SwitchListTile(
                        value: tabVisibility.showAiTab,
                        onChanged: (v) => tabVisibility.setShowAiTab(v),
                        title: Text(
                          'AI Assistant tab',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 16,
                            color: AppColors.onSurface,
                          ),
                        ),
                        activeColor: AppColors.primary,
                      ),
                      SwitchListTile(
                        value: tabVisibility.showVpnTab,
                        onChanged: (v) => tabVisibility.setShowVpnTab(v),
                        title: Text(
                          'VPN tab',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 16,
                            color: AppColors.onSurface,
                          ),
                        ),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h3.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
