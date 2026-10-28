import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:visitor_management/models/visitor_model.dart';

import '../viewmodels/visitor_view_model.dart';

class VisitorDetailsScreen extends StatefulWidget {
  const VisitorDetailsScreen({super.key, required this.visitor});

  final VisitorModel visitor;

  @override
  State<VisitorDetailsScreen> createState() => _VisitorDetailsScreenState();
}

class _VisitorDetailsScreenState extends State<VisitorDetailsScreen> {
  late VisitorModel _visitor;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _visitor = widget.visitor;
  }

  Future<void> _changeStatus() async {
    if (_isUpdatingStatus) return;

    final viewModel = context.read<VisitorViewModel>();

    // Use the latest ViewModel record if available.
    final latest = viewModel.findVisitorById(_visitor.id);
    final current = latest ?? _visitor;

    if (current.status == 'Checked Out') {
      _showMessage('This visit is already completed.');
      return;
    }

    if (current.status != 'Registered' && current.status != 'Checked In') {
      _showMessage('This visitor has an invalid status.');
      return;
    }

    setState(() {
      _visitor = current;
      _isUpdatingStatus = true;
    });

    try {
      final updated = current.status == 'Registered'
          ? await viewModel.checkIn(current.id)
          : await viewModel.checkOut(current.id);

      if (!mounted) return;

      setState(() => _visitor = updated);

      _showMessage(
        updated.status == 'Checked In'
            ? 'Visitor checked in successfully.'
            : 'Visitor checked out successfully.',
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('Unable to update status: $e');
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Color get _statusColor {
    switch (_visitor.status) {
      case 'Checked In':
        return const Color(0xFF16845B);
      case 'Checked Out':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFFB7791F);
    }
  }

  Color get _statusBackground {
    switch (_visitor.status) {
      case 'Checked In':
        return const Color(0xFFE1F5E9);
      case 'Checked Out':
        return const Color(0xFFEDF0F5);
      default:
        return const Color(0xFFFFF2D6);
    }
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return 'Not recorded';

    final date = DateTime.tryParse(value);
    if (date == null) return value;

    return '${date.toLocal().day.toString().padLeft(2, '0')}/'
        '${date.toLocal().month.toString().padLeft(2, '0')}/'
        '${date.toLocal().year} '
        '${date.toLocal().hour.toString().padLeft(2, '0')}:'
        '${date.toLocal().minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final canCheckIn = _visitor.status == 'Registered';
    final canCheckOut = _visitor.status == 'Checked In';
    final isCompleted = _visitor.status == 'Checked Out';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text(
          'Visitor Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Edit visitor',
            onPressed: () {
              context.push('/visitor-form', extra: _visitor);
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Visitor profile
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFEAECF2)),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: const Color(0xFFEAF0FF),
                  child: Text(
                    _visitor.name.isNotEmpty
                        ? _visitor.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3867E8),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _visitor.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _visitor.mobile,
                  style: const TextStyle(color: Colors.black54, fontSize: 15),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBackground,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    _visitor.status,
                    style: TextStyle(
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Visitor information
          _sectionCard(
            title: 'Visitor Information',
            icon: Icons.person_outline_rounded,
            children: [
              _detailRow('Visitor ID', _visitor.id),
              _detailRow(
                'Email',
                _visitor.email?.isNotEmpty == true
                    ? _visitor.email!
                    : 'Not provided',
              ),
              _detailRow('Visitor Type', _visitor.visitorType),
              _detailRow('Project', _visitor.project),
              _detailRow('Purpose', _visitor.purpose),
              _detailRow('Registered At', _formatDate(_visitor.createdAt)),
            ],
          ),

          const SizedBox(height: 18),

          // QR code
          _sectionCard(
            title: 'Visitor QR Code',
            icon: Icons.qr_code_2_rounded,
            children: [
              const Text(
                'Scan this code to retrieve the visitor record.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 18),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEAECF2)),
                  ),
                  child: QrImageView(
                    data: _visitor.id,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SelectableText(
                _visitor.id,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Visit timestamps
          _sectionCard(
            title: 'Visit Activity',
            icon: Icons.schedule_rounded,
            children: [
              _detailRow('Check-in Time', _formatDate(_visitor.checkInTime)),
              _detailRow('Check-out Time', _formatDate(_visitor.checkOutTime)),
            ],
          ),

          const SizedBox(height: 24),

          // Status action
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: (isCompleted || _isUpdatingStatus)
                  ? null
                  : _changeStatus,
              icon: _isUpdatingStatus
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      canCheckIn ? Icons.login_rounded : Icons.logout_rounded,
                    ),
              label: Text(
                _isUpdatingStatus
                    ? 'Updating...'
                    : canCheckIn
                    ? 'Check In Visitor'
                    : canCheckOut
                    ? 'Check Out Visitor'
                    : 'Visit Completed',
              ),
            ),
          ),

          if (isCompleted) ...[
            const SizedBox(height: 10),
            const Text(
              'This visit is complete. A new registration is required '
              'for another visit.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF3867E8)),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
