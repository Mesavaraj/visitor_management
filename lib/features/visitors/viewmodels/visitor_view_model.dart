import 'package:flutter/foundation.dart';
import 'package:visitor_management/models/visitor_model.dart';
import 'package:visitor_management/repositories/visitor_repository.dart';

class VisitorViewModel extends ChangeNotifier {
  final VisitorRepository _repository;

  VisitorViewModel(this._repository);

  List<VisitorModel> _visitors = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  List<VisitorModel> get visitors => List.unmodifiable(_visitors);

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;

  // Filter by visitor name or mobile number.
  List<VisitorModel> get filteredVisitors {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) return visitors;

    return _visitors.where((visitor) {
      return visitor.name.toLowerCase().contains(query) ||
          visitor.mobile.toLowerCase().contains(query);
    }).toList();
  }

  void searchVisitors(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // GET: Load all visitors from Supabase.
  Future<void> loadVisitors() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _visitors = await _repository.getVisitors();
    } catch (e) {
      _errorMessage = _readError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // POST: Register a visitor.
  Future<VisitorModel> createVisitor(VisitorModel visitor) async {
    try {
      final created = await _repository.createVisitor(visitor);

      _visitors = [
        created,
        ..._visitors.where((item) => item.id != created.id),
      ];

      _errorMessage = null;
      notifyListeners();

      return created;
    } catch (e) {
      _errorMessage = _readError(e);
      notifyListeners();
      rethrow;
    }
  }

  // PATCH: Update visitor information.
  Future<VisitorModel> updateVisitor(VisitorModel visitor) async {
    try {
      final updated = await _repository.updateVisitor(visitor);

      _replaceVisitor(updated);
      _errorMessage = null;
      notifyListeners();

      return updated;
    } catch (e) {
      _errorMessage = _readError(e);
      notifyListeners();
      rethrow;
    }
  }

  // PATCH: Check in a visitor.
  Future<VisitorModel> checkIn(String id) async {
    try {
      final updated = await _repository.checkIn(id);

      _replaceVisitor(updated);
      _errorMessage = null;
      notifyListeners();

      return updated;
    } catch (e) {
      _errorMessage = _readError(e);
      notifyListeners();
      rethrow;
    }
  }

  // PATCH: Check out a visitor.
  Future<VisitorModel> checkOut(String id) async {
    try {
      final updated = await _repository.checkOut(id);

      _replaceVisitor(updated);
      _errorMessage = null;
      notifyListeners();

      return updated;
    } catch (e) {
      _errorMessage = _readError(e);
      notifyListeners();
      rethrow;
    }
  }

  // DELETE: Delete a visitor.
  Future<void> deleteVisitor(String id) async {
    try {
      await _repository.deleteVisitor(id);

      _visitors.removeWhere((visitor) => visitor.id == id);
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = _readError(e);
      notifyListeners();
      rethrow;
    }
  }

  VisitorModel? findVisitorById(String id) {
    for (final visitor in _visitors) {
      if (visitor.id == id) return visitor;
    }

    return null;
  }

  void _replaceVisitor(VisitorModel updated) {
    final index = _visitors.indexWhere((visitor) => visitor.id == updated.id);

    if (index == -1) {
      _visitors.insert(0, updated);
    } else {
      _visitors[index] = updated;
    }
  }

  String _readError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<VisitorModel> getVisitorById(String id) async {
    try {
      final visitor = await _repository.getVisitorById(id);

      _replaceVisitor(visitor);
      _errorMessage = null;
      notifyListeners();

      return visitor;
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
      rethrow;
    }
  }
}
