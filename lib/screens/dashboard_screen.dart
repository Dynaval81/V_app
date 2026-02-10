import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme_provider.dart';
import '../utils/glass_kit.dart';
import '../constants/app_constants.dart';
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
    // Только обновлять при значимых изменениях (debounce: >5px)
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
    _searchOpacity.dispose();
    super.dispose();
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: GlassKit.liquidGlass(
        radius: 16,
        isDark: isDark,
        opacity: 0.08,
        useBlur: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.7), color.withOpacity(0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black45,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAirItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassKit.liquidGlass(
          radius: 16,
          isDark: isDark,
          opacity: 0.06,
          useBlur: false,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.8),
                        color.withOpacity(0.4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title, 
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle, 
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black45,
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded, 
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.08),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
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
              SliverAppBar(
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: GlassKit.liquidGlass(
                  radius: 0,
                  isDark: isDark,
                  opacity: 0.3,
                  useBlur: true,
                  child: Container(),
                ),
                title: Row(
                  children: [
                    const Icon(Icons.blur_on, color: Colors.blueAccent, size: 32),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text("VTALK", style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        fontSize: 20
                      )),
                    ),
                  ],
                ),
                actions: [
                  ValueListenableBuilder<double>(
                    valueListenable: _searchOpacity,
                    builder: (context, opacity, _) {
                      return IconButton(
                        icon: const Icon(Icons.search), 
                        onPressed: () => _showSearch(context, isDark),
                        color: isDark ? Colors.white : Colors.black.withOpacity(opacity),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: CachedNetworkImageProvider("${AppConstants.defaultAvatarUrl}?u=me"),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.black12, width: 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: "Search dashboard...",
                        hintStyle: TextStyle(color: isDark ? Colors.white24 : Colors.black26),
                        prefixIcon: Icon(Icons.search, color: isDark ? Colors.white38 : Colors.black38),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Column(
                    children: [
                      // 📊 Stats Row
                      Row(
                        children: [
                          _buildStatCard(
                            label: 'Chats',
                            value: '24',
                            icon: Icons.chat_bubble_outline,
                            color: Colors.blue,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildStatCard(
                            label: 'Online',
                            value: '12',
                            icon: Icons.person_add,
                            color: Colors.green,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildStatCard(
                            label: 'Storage',
                            value: '2.4GB',
                            icon: Icons.storage,
                            color: Colors.purple,
                            isDark: isDark,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // 🔐 Status Section
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Status',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      GlassKit.liquidGlass(
                        radius: 16,
                        isDark: isDark,
                        opacity: 0.08,
                        useBlur: false,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'VPN Connection',
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Connected • Moscow, RU',
                                      style: TextStyle(
                                        color: isDark ? Colors.white60 : Colors.black45,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.check_circle, color: Colors.green, size: 20),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // 🎯 Quick Actions
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Quick Access',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      _buildAirItem(
                        icon: Icons.vpn_lock_rounded,
                        title: 'Vtalk VPN',
                        subtitle: 'Secure & Anonymous Connection',
                        color: Colors.blue,
                        isDark: isDark,
                        onTap: () => widget.onTabSwitch(1),
                      ),

                      _buildAirItem(
                        icon: Icons.psychology_rounded,
                        title: 'AI Assistant',
                        subtitle: 'Your Personal AI Companion',
                        color: Colors.purple,
                        isDark: isDark,
                        onTap: () => widget.onTabSwitch(2),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearch(BuildContext context, bool isDark) {
    showSearch(
      context: context,
      delegate: DashboardSearchDelegate(isDark: isDark),
    );
  }
}

// Делегат для поиска в дашборде
class DashboardSearchDelegate extends SearchDelegate<String> {
  final bool isDark;

  DashboardSearchDelegate({required this.isDark});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: isDark ? Colors.white : Colors.black),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(
        'Search results for: $query',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = [
      'VPN Settings',
      'AI Assistant',
      'Storage Management',
      'Account Settings',
      'Help & Support',
      'Chat History',
    ].where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.search, color: isDark ? Colors.blue : Colors.blue),
          title: Text(
            suggestions.elementAt(index),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          onTap: () {
            query = suggestions.elementAt(index);
            showResults(context);
          },
        );
      },
    );
  }
}
