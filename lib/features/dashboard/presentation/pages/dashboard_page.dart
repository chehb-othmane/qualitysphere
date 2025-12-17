import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qualityaphere_simple/features/auth/presentation/bloc/auth_bloc.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../../../tickets/presentation/bloc/tickets_bloc.dart';
import '../../../tickets/presentation/bloc/tickets_state.dart';
import '../../../tickets/presentation/bloc/tickets_event.dart';
import '../../../tickets/presentation/pages/tickets_page.dart';
import '../../../tickets/presentation/pages/ticket_form_page.dart';
import '../../../tickets/domain/entities/ticket.dart';
import '../../../profile/presentation/pages/profile_page.dart';

// TODO: Import your auth bloc/cubit here
// import '../../../auth/presentation/bloc/auth_bloc.dart';
// import '../../../auth/presentation/bloc/auth_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  void _switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardHome(onSwitchToTickets: () => _switchToTab(1)),
      const _DashboardTickets(),
      const _DashboardProfile(),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0D121F)
          : const Color(0xFFF8FAFF),
      body: pages[_currentIndex],
      extendBody: true,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0D121F).withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.9),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavItem(
                      icon: Icons.home,
                      label: 'Home',
                      isSelected: _currentIndex == 0,
                      onTap: () => _switchToTab(0),
                      isDark: isDark,
                    ),
                    _NavItem(
                      icon: Icons.confirmation_number_outlined,
                      label: 'Tickets',
                      isSelected: _currentIndex == 1,
                      onTap: () => _switchToTab(1),
                      isDark: isDark,
                    ),
                    _NavItem(
                      icon: Icons.person_outline,
                      label: 'Profile',
                      isSelected: _currentIndex == 2,
                      onTap: () => _switchToTab(2),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? const Color(0xFF4A90E2)
        : isDark
        ? Colors.grey.shade400
        : Colors.grey.shade500;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24, fill: isSelected ? 1.0 : 0.0),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final VoidCallback onSwitchToTickets;

  const _DashboardHome({required this.onSwitchToTickets});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<TicketsBloc, TicketsState>(
      builder: (context, state) {
        final tickets = state.tickets;
        final open = tickets.where((t) => t.status == TicketStatus.open).length;
        final inProgress = tickets
            .where((t) => t.status == TicketStatus.inProgress)
            .length;
        final resolved = tickets
            .where((t) => t.status == TicketStatus.resolved)
            .length;
        final total = tickets.length;

        final userName = context.watch<AuthBloc>().state.user?.name ?? 'User';

        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header with sticky effect
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0D121F)
                      : const Color(0xFFF8FAFF),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: Color(0xFF4A90E2),
                        size: 32,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Welcome, $userName!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111318),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111318),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    children: [
                      // Stats Cards
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            _StatCard(
                              label: 'Open',
                              value: open.toString(),
                              color: const Color(0xFF40E0D0),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 16),
                            _StatCard(
                              label: 'In Progress',
                              value: inProgress.toString(),
                              color: const Color(0xFF6A5ACD),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 16),
                            _StatCard(
                              label: 'Resolved',
                              value: resolved.toString(),
                              color: const Color(0xFF4A90E2),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),

                      // Ticket Status Overview
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A233A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: isDark
                                ? Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 1,
                                  )
                                : null,
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.grey.shade100,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ticket Status Overview',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF111318),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total active tickets',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : const Color(0xFF616F89),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: _DonutChart(
                                  open: open,
                                  inProgress: inProgress,
                                  resolved: resolved,
                                  total: total,
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _ChartLegend(
                                    color: const Color(0xFF40E0D0),
                                    label: 'Open',
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 16),
                                  _ChartLegend(
                                    color: const Color(0xFF6A5ACD),
                                    label: 'In Progress',
                                    isDark: isDark,
                                  ),
                                  const SizedBox(width: 16),
                                  _ChartLegend(
                                    color: const Color(0xFF4A90E2),
                                    label: 'Resolved',
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Create New Ticket with Gradient
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4A90E2),
                                      Color(0xFF6A5ACD),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF4A90E2,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const TicketFormPage(),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.add_circle_outline,
                                          size: 20,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Create New Ticket',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // View All Tickets - Now switches to tickets tab
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: Material(
                                color: isDark
                                    ? const Color(0xFF1A233A)
                                    : const Color(0xFFE8EDF5),
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  onTap: () {
                                    // Sync tickets and switch to tickets tab
                                    context.read<TicketsBloc>().add(
                                      SyncTicketsRequested(),
                                    );
                                    onSwitchToTickets();
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Center(
                                    child: Text(
                                      'View All Tickets',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF111318),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A233A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isDark
              ? Border.all(color: Colors.white.withOpacity(0.1), width: 1)
              : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF111318),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  final int open;
  final int inProgress;
  final int resolved;
  final int total;
  final bool isDark;

  const _DonutChart({
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.total,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(160, 160),
            painter: _DonutChartPainter(
              open: open,
              inProgress: inProgress,
              resolved: resolved,
              total: total,
              isDark: isDark,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  total.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF111318),
                  ),
                ),
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.grey.shade400
                        : const Color(0xFF616F89),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final int open;
  final int inProgress;
  final int resolved;
  final int total;
  final bool isDark;

  _DonutChartPainter({
    required this.open,
    required this.inProgress,
    required this.resolved,
    required this.total,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 15.0;

    // Background circle
    final bgPaint = Paint()
      ..color = isDark ? Colors.grey.shade700 : Colors.grey.shade100
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth - 1;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    if (total == 0) return;

    // Calculate percentages
    final resolvedPercent = resolved / total;
    final inProgressPercent = inProgress / total;
    final openPercent = open / total;

    double startAngle = -math.pi / 2; // Start at top

    // Draw resolved (blue)
    if (resolved > 0) {
      final resolvedPaint = Paint()
        ..color = const Color(0xFF4A90E2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        2 * math.pi * resolvedPercent,
        false,
        resolvedPaint,
      );
      startAngle += 2 * math.pi * resolvedPercent;
    }

    // Draw in progress (purple)
    if (inProgress > 0) {
      final inProgressPaint = Paint()
        ..color = const Color(0xFF6A5ACD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        2 * math.pi * inProgressPercent,
        false,
        inProgressPaint,
      );
      startAngle += 2 * math.pi * inProgressPercent;
    }

    // Draw open (cyan)
    if (open > 0) {
      final openPaint = Paint()
        ..color = const Color(0xFF40E0D0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        2 * math.pi * openPercent,
        false,
        openPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _ChartLegend({
    required this.color,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white : const Color(0xFF111318),
          ),
        ),
      ],
    );
  }
}

class _DashboardTickets extends StatelessWidget {
  const _DashboardTickets();

  @override
  Widget build(BuildContext context) {
    return const TicketsPage(showAppBar: false);
  }
}

class _DashboardProfile extends StatelessWidget {
  const _DashboardProfile();

  @override
  Widget build(BuildContext context) {
    return const ProfilePage();
  }
}
