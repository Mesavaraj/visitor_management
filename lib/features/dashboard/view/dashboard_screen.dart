import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/visitor_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.visitors,
    required this.onRegisterVisitor,
    required this.onViewVisitors,
    required this.onScanQr,
    required this.onRefresh,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<VisitorModel> visitors;
  final VoidCallback onRegisterVisitor;
  final VoidCallback onViewVisitors;
  final VoidCallback onScanQr;

  final Future<void> Function() onRefresh;
  final bool isLoading;
  final String? errorMessage;

  bool _isSameDay(DateTime? date, DateTime today) {
    if (date == null) return false;

    final localDate = date.toLocal();

    return localDate.year == today.year &&
        localDate.month == today.month &&
        localDate.day == today.day;
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  int _totalVisitorsToday(DateTime today) {
    return visitors.where((visitor) {
      return _isSameDay(_parseDate(visitor.createdAt), today);
    }).length;
  }

  int _currentlyCheckedIn() {
    return visitors.where((visitor) => visitor.status == 'Checked In').length;
  }

  int _checkedOutToday(DateTime today) {
    return visitors.where((visitor) {
      return _isSameDay(_parseDate(visitor.checkOutTime), today);
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Visitor Management',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.6,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 15,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    DateFormat('dd MMM yyyy').format(today),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Manage visitors and daily check-ins',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                    const Text(
                      "Today's Overview",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (isLoading && visitors.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 36),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = (constraints.maxWidth - 12) / 2;

                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: cardWidth,
                                child: _StatCard(
                                  title: 'Visitors Today',
                                  value: _totalVisitorsToday(today),
                                  icon: Icons.groups_rounded,
                                  color: const Color(0xFF3867E8),
                                  background: const Color(0xFFEAF0FF),
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _StatCard(
                                  title: 'Currently Inside',
                                  value: _currentlyCheckedIn(),
                                  icon: Icons.login_rounded,
                                  color: const Color(0xFF15966A),
                                  background: const Color(0xFFE4F7EE),
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _StatCard(
                                  title: 'Checked Out Today',
                                  value: _checkedOutToday(today),
                                  icon: Icons.logout_rounded,
                                  color: const Color(0xFFD97706),
                                  background: const Color(0xFFFFF1D8),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],

                    if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE9E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.wifi_off_rounded,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () => onRefresh(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // Quick actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _ActionCard(
                      icon: Icons.person_add_alt_1_rounded,
                      title: 'Register Visitor',
                      subtitle: 'Add a new visitor record',
                      color: const Color(0xFF3867E8),
                      onTap: onRegisterVisitor,
                    ),
                    const SizedBox(height: 12),

                    _ActionCard(
                      icon: Icons.people_alt_rounded,
                      title: 'Visitor List',
                      subtitle: 'Search and manage visitors',
                      color: const Color(0xFF15966A),
                      onTap: onViewVisitors,
                    ),
                    const SizedBox(height: 12),

                    _ActionCard(
                      icon: Icons.qr_code_scanner_rounded,
                      title: 'Scan QR Code',
                      subtitle: 'Identify a visitor and manage entry',
                      color: const Color(0xFF805AD5),
                      onTap: onScanQr,
                    ),

                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        'Visitor Management System',
                        style: TextStyle(color: Colors.black45, fontSize: 12),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 145),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(height: 16),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAECF2)),
          ),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
