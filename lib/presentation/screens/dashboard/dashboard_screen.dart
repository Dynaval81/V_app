import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/constants/app_constants.dart';
import 'package:vtalk_app/core/controllers/tab_visibility_controller.dart';

/// HAI3 Dashboard: App info, Donations, Version, AI/VPN toggles (Airy).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _SectionCard(
                    title: 'Tabs',
                    children: [
                      DropdownButton<String>(
                        value: tabVisibility.showAiTab ? 'Show AI' : 'Hide AI',
                        onChanged: (value) {
                          if (value != null) {
                            tabVisibility.setShowAiTab(value == 'Show AI');
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'Show AI', child: Text('Show AI')),
                          DropdownMenuItem(value: 'Hide AI', child: Text('Hide AI')),
                        ],
                        isExpanded: true,
                        hint: Text('AI Assistant tab'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButton<String>(
                        value: tabVisibility.showVpnTab ? 'Show VPN' : 'Hide VPN',
                        onChanged: (value) {
                          if (value != null) {
                            tabVisibility.setShowVpnTab(value == 'Show VPN');
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 'Show VPN', child: Text('Show VPN')),
                          DropdownMenuItem(value: 'Hide VPN', child: Text('Hide VPN')),
                        ],
                        isExpanded: true,
                        hint: Text('VPN tab'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'App info',
                    children: [
                      _InfoRow(label: 'App', value: AppConstants.appName),
                      _InfoRow(label: 'Version', value: '${AppConstants.appVersion} (${AppConstants.appBuildNumber})'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Donations',
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
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
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Version',
                    children: [
                      _InfoRow(label: 'Build', value: AppConstants.appBuildNumber),
                      _InfoRow(label: 'API', value: AppConstants.apiVersion),
                    ],
                  ),
                  const SizedBox(height: 32),
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

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
