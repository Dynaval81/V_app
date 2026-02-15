import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme_provider.dart';
import '../utils/glass_kit.dart';
import '../constants/app_constants.dart';
import '../widgets/vtalk_header.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import './account_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onTabSwitch;

  const DashboardScreen({super.key, required this.onTabSwitch});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _searchOpacity = ValueNotifier(0.0);
  double _lastOffset = 0.0;
  final _promoCodeController = TextEditingController();
  bool _isActivating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    if ((offset - _lastOffset).abs() > 5.0) {
      _lastOffset = offset;
      final newOpacity = (offset / 80).clamp(0.0, 1.0);
      if ((newOpacity - _searchOpacity.value).abs() > 0.05) {
        _searchOpacity.value = newOpacity;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _promoCodeController.dispose();
    _searchOpacity.dispose();
    super.dispose();
  }

  Future<void> _activatePromoCode() async {
    if (_promoCodeController.text.trim().isEmpty) {
      _showSnackBar('Please enter a promo code', Colors.orange);
      return;
    }

    setState(() => _isActivating = true);

    try {
      final result = await ApiService().activatePremium(_promoCodeController.text.trim());
      
      if (result['success']) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.refreshUserData();
        
        _showSnackBar('Premium activated successfully!', Colors.green);
        _promoCodeController.clear();
      } else {
        _showSnackBar(result['error'] ?? 'Activation failed', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Network error: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isActivating = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        leading: Icon(icon, color: AppColors.primary, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: GlassKit.mainBackground(isDark),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: VtalkHeader(
                  title: "Dashboard",
                  showScrollAnimation: false,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Elements Store Section
                    _buildExpansionTile(
                      icon: Icons.tune_rounded,
                      title: 'Elements Store',
                      children: [
                        SwitchListTile(
                          value: false, // TODO: Connect to actual state
                          onChanged: (value) {
                            HapticFeedback.lightImpact();
                            // TODO: Implement AI tab toggle
                          },
                          title: const Text(
                            'AI Assistant tab',
                            style: TextStyle(fontSize: 16, color: AppColors.onSurface),
                          ),
                          activeColor: AppColors.primary,
                        ),
                        SwitchListTile(
                          value: false, // TODO: Connect to actual state
                          onChanged: (value) {
                            HapticFeedback.lightImpact();
                            // TODO: Implement VPN tab toggle
                          },
                          title: const Text(
                            'VPN tab',
                            style: TextStyle(fontSize: 16, color: AppColors.onSurface),
                          ),
                          activeColor: AppColors.primary,
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
                                style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
                              ),
                              Text(
                                AppConstants.appName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface),
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
                                style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
                              ),
                              Text(
                                '${AppConstants.appVersion} (${AppConstants.appBuildNumber})',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface),
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
                              color: AppColors.onSurfaceVariant,
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
                                style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
                              ),
                              Text(
                                AppConstants.appBuildNumber,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface),
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
                                style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
                              ),
                              Text(
                                AppConstants.apiVersion,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Premium Activation Section
                    Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.card_giftcard, color: Colors.amber, size: 24),
                                const SizedBox(width: 12),
                                const Text(
                                  'Activate Premium',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _promoCodeController,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter promo code',
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                                prefixIcon: Icon(Icons.key, color: isDark ? Colors.white54 : Colors.black54),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isActivating ? null : _activatePromoCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _isActivating
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                        ),
                                      )
                                    : const Text(
                                        'Activate',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Account Section
                    Container(
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
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                        title: const Text(
                          'Account Settings',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.onSurfaceVariant),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            CupertinoPageRoute(builder: (context) => const AccountSettingsScreen()),
                          );
                        },
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
