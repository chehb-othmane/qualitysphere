import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/ticket.dart';
import '../bloc/tickets_bloc.dart';
import '../bloc/tickets_event.dart';
import '../bloc/tickets_state.dart';
import 'ticket_form_page.dart';

class TicketsPage extends StatefulWidget {
  final bool showAppBar;
  const TicketsPage({super.key, this.showAppBar = false});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  TicketStatus? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return const Color(0xFF3B82F6); // primary blue
      case TicketStatus.inProgress:
        return const Color(0xFF8B5CF6); // accent purple
      case TicketStatus.resolved:
        return const Color(0xFF14B8A6); // accent teal
    }
  }

  Color _getStatusBgColor(TicketStatus status, bool isDark) {
    switch (status) {
      case TicketStatus.open:
        return isDark
            ? const Color(0xFF1E3A8A).withOpacity(0.3)
            : const Color(0xFFEFF6FF);
      case TicketStatus.inProgress:
        return isDark
            ? const Color(0xFF5B21B6).withOpacity(0.3)
            : const Color(0xFFF5F3FF);
      case TicketStatus.resolved:
        return isDark
            ? const Color(0xFF134E4A).withOpacity(0.3)
            : const Color(0xFFF0FDFA);
    }
  }

  String _getStatusLabel(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
    }
  }

  List<Ticket> _filterTickets(List<Ticket> tickets) {
    var filtered = tickets;

    // Apply status filter
    if (_selectedFilter != null) {
      filtered = filtered.where((t) => t.status == _selectedFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (t) =>
                t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                t.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF101622) : const Color(0xFFF6F6F8);
    final cardColor = isDark ? const Color(0xFF1A202C) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final textSecondary = isDark
        ? const Color(0xFFA0AEC0)
        : const Color(0xFF8A8A8E);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: widget.showAppBar ? AppBar(title: const Text('Tickets')) : null,
      body: BlocConsumer<TicketsBloc, TicketsState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.tickets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredTickets = _filterTickets(state.tickets);

          return Column(
            children: [
              // Header with better padding
              Container(
                color: bgColor,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tickets',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search tickets...',
                      hintStyle: TextStyle(color: textSecondary),
                      prefixIcon: Icon(
                        Icons.search,
                        color: const Color(0xFF8B5CF6),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: TextStyle(color: textPrimary),
                  ),
                ),
              ),

              // Filter Chips
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip(
                      label: 'All',
                      isSelected: _selectedFilter == null,
                      onTap: () {
                        setState(() {
                          _selectedFilter = null;
                        });
                      },
                      isDark: isDark,
                      icon: Icons.tune,
                    ),
                    const SizedBox(width: 12),
                    _buildStatusFilterChip(
                      label: 'Open',
                      status: TicketStatus.open,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _buildStatusFilterChip(
                      label: 'In Progress',
                      status: TicketStatus.inProgress,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _buildStatusFilterChip(
                      label: 'Resolved',
                      status: TicketStatus.resolved,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tickets List
              Expanded(
                child: filteredTickets.isEmpty
                    ? Center(
                        child: Text(
                          'No tickets found',
                          style: TextStyle(color: textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: filteredTickets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final ticket = filteredTickets[index];
                          return _buildTicketCard(
                            ticket,
                            context,
                            isDark,
                            cardColor,
                            textPrimary,
                            textSecondary,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TicketFormPage()),
          );
        },
        backgroundColor: const Color(0xFF8B5CF6),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? const Color(0xFF1A202C) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null
              : Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE2E8F0),
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF8B5CF6),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : const Color(0xFF1C1C1E)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterChip({
    required String label,
    required TicketStatus status,
    required bool isDark,
  }) {
    final isSelected = _selectedFilter == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = isSelected ? null : status;
        });
      },
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A202C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? _getStatusColor(status)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(
    Ticket ticket,
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final createdDate = DateFormat('MMM dd, yyyy').format(ticket.createdAt);

    return GestureDetector(
      onTap: () {
        _showStatusMenu(context, ticket);
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF2D3748) : const Color(0xFFF1F5F9),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Status color indicator
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _getStatusColor(ticket.status),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      ticket.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusBgColor(ticket.status, isDark),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusLabel(ticket.status),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: _getStatusColor(ticket.status),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Created: $createdDate',
                          style: TextStyle(fontSize: 14, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusMenu(BuildContext context, Ticket ticket) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A202C) : Colors.white;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 8),
              child: Text(
                'Change Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                ),
              ),
            ),

            // Status options
            ListTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(TicketStatus.open),
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Open'),
              trailing: ticket.status == TicketStatus.open
                  ? const Icon(Icons.check, color: Color(0xFF3B82F6))
                  : null,
              onTap: () {
                context.read<TicketsBloc>().add(
                  UpdateTicketStatusRequested(
                    id: ticket.id,
                    status: TicketStatus.open,
                  ),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(TicketStatus.inProgress),
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('In Progress'),
              trailing: ticket.status == TicketStatus.inProgress
                  ? const Icon(Icons.check, color: Color(0xFF8B5CF6))
                  : null,
              onTap: () {
                context.read<TicketsBloc>().add(
                  UpdateTicketStatusRequested(
                    id: ticket.id,
                    status: TicketStatus.inProgress,
                  ),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(TicketStatus.resolved),
                  shape: BoxShape.circle,
                ),
              ),
              title: const Text('Resolved'),
              trailing: ticket.status == TicketStatus.resolved
                  ? const Icon(Icons.check, color: Color(0xFF14B8A6))
                  : null,
              onTap: () {
                context.read<TicketsBloc>().add(
                  UpdateTicketStatusRequested(
                    id: ticket.id,
                    status: TicketStatus.resolved,
                  ),
                );
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Create New Ticket Button
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context); // Close the bottom sheet first
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TicketFormPage()),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create New Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
