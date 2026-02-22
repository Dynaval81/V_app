import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtalk_app/core/constants.dart';
import 'package:vtalk_app/core/controllers/vpn_controller.dart';
import 'package:vtalk_app/data/models/server_model.dart';
import 'package:vtalk_app/l10n/app_localizations.dart';
import 'dart:ui';

/// HAI3 Zen VPN Screen
/// One button. Two menus. Nothing else.
class VpnScreen extends StatefulWidget {
  const VpnScreen({super.key});

  @override
  State<VpnScreen> createState() => _VpnScreenState();
}

class _VpnScreenState extends State<VpnScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VpnController>().initialize();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<VpnController>(
          builder: (context, controller, _) {
            return Column(
              children: [
                _buildHeader(context, controller),
                Expanded(child: _buildCenter(context, controller)),
                _buildFooter(context, controller),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, VpnController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'VPN',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
              color: AppColors.onSurface,
            ),
          ),
          _StatusChip(controller: controller),
        ],
      ),
    );
  }

  // ── Center (Zen Button) ───────────────────────────────────────────

  Widget _buildCenter(BuildContext context, VpnController controller) {
    final isConnected = controller.isConnected;
    final isConnecting = controller.isConnecting ||
        controller.connectionState == VpnConnectionState.disconnecting;

    final color = isConnected
        ? const Color(0xFF34C759)
        : isConnecting
            ? const Color(0xFFFF9500)
            : AppColors.primary;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Server info above button
        AnimatedOpacity(
          opacity: controller.selectedServer != null ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Text(
              controller.autoMode
                  ? 'AI — авто-выбор'
                  : controller.selectedServer?.location ?? '',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.onSurface.withOpacity(0.5),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        // Zen Button
        GestureDetector(
          onTap: isConnecting ? null : controller.toggleConnection,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final scale = isConnected ? _pulseAnimation.value : 1.0;
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isConnected ? 0.35 : 0.15),
                    blurRadius: isConnected ? 60 : 30,
                    spreadRadius: isConnected ? 10 : 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: isConnecting
                  ? Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          color: color,
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.power_settings_new_rounded,
                      size: 64,
                      color: color,
                    ),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Status label
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _statusLabel(controller),
            key: ValueKey(controller.connectionState),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.onSurface.withOpacity(0.45),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  String _statusLabel(VpnController c) {
    switch (c.connectionState) {
      case VpnConnectionState.connected:
        return 'Подключено';
      case VpnConnectionState.connecting:
        return 'Подключение...';
      case VpnConnectionState.disconnecting:
        return 'Отключение...';
      case VpnConnectionState.disconnected:
        return 'Нажмите для подключения';
    }
  }

  // ── Footer (two icon buttons) ─────────────────────────────────────

  Widget _buildFooter(BuildContext context, VpnController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _FooterAction(
            icon: Icons.language_rounded,
            label: 'Серверы',
            onTap: () => _showNodesSheet(context, controller),
          ),
          _FooterAction(
            icon: Icons.tune_rounded,
            label: 'Туннель',
            onTap: () => _showRoutingSheet(context, controller),
          ),
        ],
      ),
    );
  }

  // ── Nodes Bottom Sheet ────────────────────────────────────────────

  void _showNodesSheet(BuildContext context, VpnController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: const _NodesSheet(),
      ),
    );
  }

  // ── Routing Bottom Sheet ──────────────────────────────────────────

  void _showRoutingSheet(BuildContext context, VpnController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: const _RoutingSheet(),
      ),
    );
  }
}

// ── Status Chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final VpnController controller;
  const _StatusChip({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isConnected = controller.isConnected;
    final color = isConnected
        ? const Color(0xFF34C759)
        : AppColors.onSurface.withOpacity(0.25);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isConnected ? 'ON' : 'OFF',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isConnected
                  ? const Color(0xFF34C759)
                  : AppColors.onSurface.withOpacity(0.4),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer Action Button ──────────────────────────────────────────────────────

class _FooterAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FooterAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.onSurface.withOpacity(0.6), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurface.withOpacity(0.45),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nodes Bottom Sheet ────────────────────────────────────────────────────────

class _NodesSheet extends StatelessWidget {
  const _NodesSheet();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VpnController>();

    return _GlassSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandle(),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Text(
              'Серверы',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),

          // AI Auto mode
          _NodeTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.primary, size: 20),
            ),
            title: 'AI — авто-выбор',
            subtitle: 'Минимальный пинг',
            trailing: controller.autoMode
                ? const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 22)
                : null,
            onTap: () {
              controller.setAutoMode(true);
              Navigator.pop(context);
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Divider(height: 1),
          ),

          // Server list
          if (controller.isLoadingServers)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            ...controller.servers.map((server) {
              final ping = controller.pingFor(server.nodeId);
              final isSelected = !controller.autoMode &&
                  controller.selectedServer?.nodeId == server.nodeId;
              return _NodeTile(
                leading: Text(
                  server.flagEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
                title: server.location,
                subtitle: ping != null ? '$ping ms' : '— ms',
                pingMs: ping,
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.primary, size: 22)
                    : null,
                onTap: () {
                  controller.selectServer(server);
                  Navigator.pop(context);
                },
              );
            }),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

// ── Routing Bottom Sheet ──────────────────────────────────────────────────────

class _RoutingSheet extends StatefulWidget {
  const _RoutingSheet();

  @override
  State<_RoutingSheet> createState() => _RoutingSheetState();
}

class _RoutingSheetState extends State<_RoutingSheet> {
  final TextEditingController _domainsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final controller = context.read<VpnController>();
    _domainsController.text = controller.customDomains.join('\n');
  }

  @override
  void dispose() {
    _domainsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VpnController>();

    return _GlassSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandle(),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: Text(
              'Туннелирование',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),

          // Full tunnel
          _RoutingTile(
            icon: Icons.public_rounded,
            title: 'Весь трафик',
            subtitle: 'Всё через VPN',
            selected: controller.routingMode == VpnRoutingMode.full,
            onTap: () => controller.setRoutingMode(VpnRoutingMode.full),
          ),

          // VTalk only
          _RoutingTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Только VTalk',
            subtitle: 'Мессенджер через VPN, остальное напрямую',
            selected: controller.routingMode == VpnRoutingMode.vtalkOnly,
            onTap: () => controller.setRoutingMode(VpnRoutingMode.vtalkOnly),
          ),

          // Custom domains
          _RoutingTile(
            icon: Icons.edit_note_rounded,
            title: 'Свои адреса',
            subtitle: 'Указать домены вручную',
            selected: controller.routingMode == VpnRoutingMode.custom,
            onTap: () => controller.setRoutingMode(VpnRoutingMode.custom),
          ),

          // Custom domains input — shows when custom mode selected
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: controller.routingMode == VpnRoutingMode.custom
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _domainsController,
                          maxLines: 4,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'example.com\nsite.org',
                            hintStyle: TextStyle(
                              color: AppColors.onSurface.withOpacity(0.35),
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF1F3F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              final domains = _domainsController.text
                                  .split('\n')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();
                              controller.setCustomDomains(domains);
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Сохранить'),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }
}

// ── Shared Sheet Widgets ──────────────────────────────────────────────────────

class _GlassSheet extends StatelessWidget {
  final Widget child;
  const _GlassSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 40,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.onSurface.withOpacity(0.12),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class _NodeTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final int? pingMs;
  final Widget? trailing;
  final VoidCallback onTap;

  const _NodeTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.pingMs,
    this.trailing,
    required this.onTap,
  });

  Color _pingColor(int ms) {
    if (ms < 80) return const Color(0xFF34C759);
    if (ms < 150) return const Color(0xFFFF9500);
    return const Color(0xFFFF3B30);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            SizedBox(width: 40, child: leading),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: pingMs != null
                          ? _pingColor(pingMs!)
                          : AppColors.onSurface.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _RoutingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _RoutingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withOpacity(0.1)
                    : const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected
                    ? AppColors.primary
                    : AppColors.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurface.withOpacity(0.45),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}