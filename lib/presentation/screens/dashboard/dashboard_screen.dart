import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtalk_app/constants/app_constants.dart';
import 'package:vtalk_app/constants/app_colors.dart';
import 'package:vtalk_app/core/controllers/tab_visibility_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutomaticKeepAliveClientMixin {
  bool _showAiTab = true;
  bool _showVpnTab = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTabVisibility();
  }

  Future<void> _loadTabVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showAiTab = prefs.getBool('dashboard_show_ai_tab') ?? true;
      _showVpnTab = prefs.getBool('dashboard_show_vpn_tab') ?? true;
    });
  }

  Future<void> _saveTabVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dashboard_show_ai_tab', _showAiTab);
    await prefs.setBool('dashboard_show_vpn_tab', _showVpnTab);
    
    // Notify TabVisibilityController about the change
    context.read<TabVisibilityController>().setShowAiTab(_showAiTab);
    context.read<TabVisibilityController>().setShowVpnTab(_showVpnTab);
  }

  Widget _buildExpansionTile({
    required IconData icon,
    required String title,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        key: PageStorageKey<String>(title),
        initiallyExpanded: initiallyExpanded,
        shape: const Border(),
        backgroundColor: Colors.transparent,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Icon(icon, color: AppColors.primaryBlue, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              
              // Elements Store Section
              _buildExpansionTile(
                icon: Icons.tune_rounded,
                title: 'Elements Store',
                children: [
                  SwitchListTile(
                    value: _showAiTab,
                    onChanged: (value) {
                      setState(() => _showAiTab = value);
                      _saveTabVisibility();
                    },
                    title: const Text(
                      'AI Assistant tab',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    activeColor: AppColors.primaryBlue,
                  ),
                  SwitchListTile(
                    value: _showVpnTab,
                    onChanged: (value) {
                      setState(() => _showVpnTab = value);
                      _saveTabVisibility();
                    },
                    title: const Text(
                      'VPN tab',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    activeColor: AppColors.primaryBlue,
                  ),
                ],
              ),
              
              // App Info Section
              _buildExpansionTile(
                icon: Icons.info_outline_rounded,
                title: 'App Info',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'App',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const Text(
                          'V-Talk',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Version',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const Text(
                          '1.0.0 (1)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Donations Section
              _buildExpansionTile(
                icon: Icons.favorite_outline_rounded,
                title: 'Donations',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Support the project – donations help keep V-Talk free and open.',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              
              // Version Details Section
              _buildExpansionTile(
                icon: Icons.memory_rounded,
                title: 'Version Details',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Build',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const Text(
                          '1',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'API',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const Text(
                          'v1.0',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
