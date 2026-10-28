import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visitor_management/features/visitors/viewmodels/visitor_view_model.dart';
import 'package:visitor_management/models/visitor_model.dart';

class VisitorListScreen extends StatefulWidget {
  const VisitorListScreen({
    super.key,
    required this.onOpenDetails,
    required this.onEditVisitor,
    required this.onRegisterVisitor,
  });

  final ValueChanged<VisitorModel> onOpenDetails;
  final ValueChanged<VisitorModel> onEditVisitor;
  final VoidCallback onRegisterVisitor;

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final viewModel = context.read<VisitorViewModel>();

      if (viewModel.visitors.isEmpty) {
        viewModel.loadVisitors();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    VisitorModel visitor,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete visitor?'),
          content: Text(
            'Are you sure you want to delete ${visitor.name}? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    try {
      await context.read<VisitorViewModel>().deleteVisitor(visitor.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${visitor.name} deleted successfully')),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Checked In':
        return const Color(0xFF16845B);
      case 'Checked Out':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFFB7791F);
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Checked In':
        return const Color(0xFFE1F5E9);
      case 'Checked Out':
        return const Color(0xFFEDF0F5);
      default:
        return const Color(0xFFFFF2D6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Visitors',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Refresh visitors',
            onPressed: () => context.read<VisitorViewModel>().loadVisitors(),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<VisitorViewModel>(
        builder: (context, viewModel, child) {
          final visitors = viewModel.filteredVisitors;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: viewModel.searchVisitors,
                  decoration: InputDecoration(
                    hintText: 'Search name or mobile number',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              viewModel.searchVisitors('');
                            },
                            icon: const Icon(Icons.close_rounded),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'All Visitors',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${visitors.length} records',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),

              if (viewModel.isLoading && viewModel.visitors.isNotEmpty)
                const LinearProgressIndicator(minHeight: 2),

              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Material(
                    color: const Color(0xFFFFE8E8),
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      leading: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                      ),
                      title: const Text('Unable to load visitors'),
                      subtitle: Text(viewModel.errorMessage!),
                      trailing: IconButton(
                        tooltip: 'Retry',
                        onPressed: viewModel.loadVisitors,
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: Builder(
                  builder: (context) {
                    if (viewModel.isLoading && viewModel.visitors.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (viewModel.visitors.isEmpty &&
                        viewModel.errorMessage != null) {
                      return _EmptyState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Could not load visitors',
                        message:
                            'Check your internet connection and try again.',
                        actionLabel: 'Retry',
                        onAction: viewModel.loadVisitors,
                      );
                    }

                    if (visitors.isEmpty) {
                      return _EmptyState(
                        icon: Icons.people_outline_rounded,
                        title: viewModel.searchQuery.isNotEmpty
                            ? 'No matching visitors'
                            : 'No visitors yet',
                        message: viewModel.searchQuery.isNotEmpty
                            ? 'Try another name or mobile number.'
                            : 'Register your first visitor to get started.',
                        actionLabel: viewModel.searchQuery.isNotEmpty
                            ? 'Clear search'
                            : 'Register Visitor',
                        onAction: () {
                          if (viewModel.searchQuery.isNotEmpty) {
                            _searchController.clear();
                            viewModel.searchVisitors('');
                          } else {
                            widget.onRegisterVisitor();
                          }
                        },
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: viewModel.loadVisitors,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        itemCount: visitors.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final visitor = visitors[index];

                          return Card(
                            color: Colors.white,
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFFEAECF2)),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => widget.onOpenDetails(visitor),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: const Color(
                                            0xFFEAF0FF,
                                          ),
                                          child: Text(
                                            visitor.name.isNotEmpty
                                                ? visitor.name[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: Color(0xFF3867E8),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                visitor.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                visitor.mobile,
                                                style: const TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          tooltip: 'Visitor actions',
                                          onSelected: (value) {
                                            if (value == 'edit') {
                                              widget.onEditVisitor(visitor);
                                            } else if (value == 'delete') {
                                              _confirmDelete(context, visitor);
                                            }
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit_outlined),
                                                  SizedBox(width: 10),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text('Delete'),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Divider(height: 1),
                                    ),

                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.apartment_rounded,
                                          size: 17,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(width: 7),
                                        Expanded(
                                          child: Text(
                                            visitor.project,
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          visitor.visitorType,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _statusBackground(
                                              visitor.status,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            visitor.status,
                                            style: TextStyle(
                                              color: _statusColor(
                                                visitor.status,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        const Text(
                                          'View details',
                                          style: TextStyle(
                                            color: Color(0xFF3867E8),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 12,
                                          color: Color(0xFF3867E8),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onRegisterVisitor,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Register'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.black26),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
