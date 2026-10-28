import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:visitor_management/features/visitors/viewmodels/visitor_view_model.dart';
import 'package:visitor_management/models/visitor_model.dart';

class VisitorFormScreen extends StatefulWidget {
  const VisitorFormScreen({super.key, this.visitor});

  final VisitorModel? visitor;

  @override
  State<VisitorFormScreen> createState() => _VisitorFormScreenState();
}

class _VisitorFormScreenState extends State<VisitorFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _purposeController;

  String _visitorType = 'Customer';
  String _project = 'Project A';
  bool _isSaving = false;

  bool get _isEditing => widget.visitor != null;

  @override
  void initState() {
    super.initState();

    final visitor = widget.visitor;

    _nameController = TextEditingController(text: visitor?.name ?? '');
    _mobileController = TextEditingController(text: visitor?.mobile ?? '');
    _emailController = TextEditingController(text: visitor?.email ?? '');
    _purposeController = TextEditingController(text: visitor?.purpose ?? '');

    if (visitor != null) {
      _visitorType = visitor.visitorType;
      _project = visitor.project;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the visitor name';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    final mobile = value?.trim() ?? '';

    if (mobile.isEmpty) {
      return 'Please enter the mobile number';
    }

    if (!RegExp(r'^\d{10}$').hasMatch(mobile)) {
      return 'Enter exactly 10 digits';
    }

    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return null;

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  Future<void> _saveVisitor() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final previous = widget.visitor;

    final visitor = VisitorModel(
      id: previous?.id ?? '',
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      visitorType: _visitorType,
      project: _project,
      purpose: _purposeController.text.trim(),
      status: previous?.status ?? 'Registered',
      createdAt: previous?.createdAt ?? '',
      checkInTime: previous?.checkInTime,
      checkOutTime: previous?.checkOutTime,
    );

    try {
      final viewModel = context.read<VisitorViewModel>();

      final savedVisitor = _isEditing
          ? await viewModel.updateVisitor(visitor)
          : await viewModel.createVisitor(visitor);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Visitor updated successfully'
                : 'Visitor registered successfully',
          ),
        ),
      );

      // Open the details screen with the server-returned visitor.
      context.go('/visitor-details', extra: savedVisitor);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to save visitor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Visitor' : 'Register Visitor',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEAECF2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Visitor Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Enter the visitor details below.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    _label('Visitor Name *'),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      validator: _validateName,
                      decoration: _inputDecoration(
                        hint: 'Enter full name',
                        icon: Icons.person_outline,
                      ),
                    ),
                    const SizedBox(height: 18),

                    _label('Mobile Number *'),
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      validator: _validateMobile,
                      decoration: _inputDecoration(
                        hint: '10-digit mobile number',
                        icon: Icons.phone_outlined,
                      ).copyWith(counterText: ''),
                    ),
                    const SizedBox(height: 18),

                    _label('Email Address'),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      decoration: _inputDecoration(
                        hint: 'Enter email (optional)',
                        icon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 18),

                    _label('Visitor Type *'),
                    DropdownButtonFormField<String>(
                      initialValue: _visitorType,
                      decoration: _inputDecoration(
                        hint: 'Select visitor type',
                        icon: Icons.badge_outlined,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Customer',
                          child: Text('Customer'),
                        ),
                        DropdownMenuItem(
                          value: 'Vendor',
                          child: Text('Vendor'),
                        ),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _visitorType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 18),

                    _label('Project *'),
                    DropdownButtonFormField<String>(
                      initialValue: _project,
                      decoration: _inputDecoration(
                        hint: 'Select project',
                        icon: Icons.apartment_outlined,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Project A',
                          child: Text('Project A'),
                        ),
                        DropdownMenuItem(
                          value: 'Project B',
                          child: Text('Project B'),
                        ),
                        DropdownMenuItem(
                          value: 'Project C',
                          child: Text('Project C'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _project = value);
                        }
                      },
                    ),
                    const SizedBox(height: 18),

                    _label('Purpose of Visit *'),
                    TextFormField(
                      controller: _purposeController,
                      minLines: 3,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the purpose of visit';
                        }
                        return null;
                      },
                      decoration: _inputDecoration(
                        hint: 'Why is the visitor visiting?',
                        icon: Icons.description_outlined,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _saveVisitor,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _isEditing
                              ? Icons.save_outlined
                              : Icons.person_add_alt_1,
                        ),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : _isEditing
                        ? 'Update Visitor'
                        : 'Register Visitor',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 21),
      filled: true,
      fillColor: const Color(0xFFF8F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E4EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E4EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3867E8), width: 1.5),
      ),
    );
  }
}
