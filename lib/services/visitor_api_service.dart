import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import '../models/visitor_model.dart';

class VisitorApiService {
  final http.Client _client;

  VisitorApiService(this._client);

  Uri get _visitorsUri =>
      Uri.parse('${AppConfig.supabaseUrl}/rest/v1/visitors');

  Map<String, String> get _headers => {
    'apikey': AppConfig.supabasePublishableKey,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Prefer': 'return=representation',
    'Authorization': 'Bearer ${AppConfig.supabasePublishableKey}',
  };

  // GET: Retrieve all visitors.
  Future<List<VisitorModel>> getVisitors() async {
    final uri = _visitorsUri.replace(
      queryParameters: {'select': '*', 'order': 'created_at.desc'},
    );

    final response = await _client
        .get(uri, headers: _headers)
        .timeout(AppConfig.requestTimeout);

    _checkResponse(response, {200});

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw const FormatException('Expected a list of visitors from Supabase.');
    }

    return decoded.map((item) {
      if (item is! Map) {
        throw const FormatException('Invalid visitor record.');
      }

      return VisitorModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  // GET: Retrieve one visitor by server-generated ID.
  Future<VisitorModel> getVisitorById(String id) async {
    final uri = _visitorsUri.replace(
      queryParameters: {'select': '*', 'id': 'eq.$id', 'limit': '1'},
    );

    final response = await _client
        .get(uri, headers: _headers)
        .timeout(AppConfig.requestTimeout);

    _checkResponse(response, {200});

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List || decoded.isEmpty) {
      throw Exception('Visitor not found.');
    }

    return VisitorModel.fromJson(
      Map<String, dynamic>.from(decoded.first as Map),
    );
  }

  // POST: Register a new visitor.
  // Supabase generates the visitor ID and created_at.
  Future<VisitorModel> createVisitor(VisitorModel visitor) async {
    final response = await _client
        .post(
          _visitorsUri,
          headers: _headers,
          body: jsonEncode(visitor.toInsertJson()),
        )
        .timeout(AppConfig.requestTimeout);

    _checkResponse(response, {201});

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List || decoded.isEmpty) {
      throw Exception(
        'Visitor was created, but no visitor record was returned.',
      );
    }

    return VisitorModel.fromJson(
      Map<String, dynamic>.from(decoded.first as Map),
    );
  }

  // PATCH: Update visitor information.
  Future<VisitorModel> updateVisitor(VisitorModel visitor) async {
    final uri = _visitorsUri.replace(
      queryParameters: {'id': 'eq.${visitor.id}', 'select': '*'},
    );

    final response = await _client
        .patch(uri, headers: _headers, body: jsonEncode(visitor.toUpdateJson()))
        .timeout(AppConfig.requestTimeout);

    _checkResponse(response, {200});

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List || decoded.isEmpty) {
      throw Exception('Visitor not found or update was not permitted.');
    }

    return VisitorModel.fromJson(
      Map<String, dynamic>.from(decoded.first as Map),
    );
  }

  // PATCH: Check in a registered visitor.
  Future<VisitorModel> checkIn(String id) async {
    return _updateStatus(
      id: id,
      expectedStatus: 'Registered',
      newStatus: 'Checked In',
      timestampColumn: 'check_in_time',
    );
  }

  // PATCH: Check out a visitor who is currently checked in.
  Future<VisitorModel> checkOut(String id) async {
    return _updateStatus(
      id: id,
      expectedStatus: 'Checked In',
      newStatus: 'Checked Out',
      timestampColumn: 'check_out_time',
    );
  }

  Future<VisitorModel> _updateStatus({
    required String id,
    required String expectedStatus,
    required String newStatus,
    required String timestampColumn,
  }) async {
    // Conditional update prevents repeated status transitions.
    final uri = _visitorsUri.replace(
      queryParameters: {
        'id': 'eq.$id',
        'status': 'eq.$expectedStatus',
        'select': '*',
      },
    );

    final now = DateTime.now().toUtc().toIso8601String();

    final response = await _client
        .patch(
          uri,
          headers: _headers,
          body: jsonEncode({'status': newStatus, timestampColumn: now}),
        )
        .timeout(AppConfig.requestTimeout);

    _checkResponse(response, {200});

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List || decoded.isEmpty) {
      throw Exception(
        'Cannot change status. Check the visitor status and try again.',
      );
    }

    return VisitorModel.fromJson(
      Map<String, dynamic>.from(decoded.first as Map),
    );
  }

  // DELETE: Remove a visitor.
  Future<void> deleteVisitor(String id) async {
    final uri = _visitorsUri.replace(
      queryParameters: {'id': 'eq.$id', 'select': 'id'},
    );

    final response = await _client
        .delete(uri, headers: _headers)
        .timeout(AppConfig.requestTimeout);

    _checkResponse(response, {200, 204});

    // An empty result can mean the row did not exist
    // or the database policy did not permit deletion.
    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! List || decoded.isEmpty) {
        throw Exception('Visitor not found or deletion was not permitted.');
      }
    }
  }

  void _checkResponse(http.Response response, Set<int> acceptedStatuses) {
    if (acceptedStatuses.contains(response.statusCode)) {
      return;
    }

    String message = 'Request failed';

    try {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map) {
        message =
            decoded['message']?.toString() ??
            decoded['details']?.toString() ??
            decoded['error']?.toString() ??
            message;
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        message = response.body;
      }
    }

    throw Exception('$message (HTTP ${response.statusCode})');
  }
}
