import '../models/visitor_model.dart';
import '../services/visitor_api_service.dart';

class VisitorRepository {
  final VisitorApiService _apiService;

  VisitorRepository(this._apiService);

  Future<List<VisitorModel>> getVisitors() {
    return _apiService.getVisitors();
  }

  Future<VisitorModel> getVisitorById(String id) {
    return _apiService.getVisitorById(id);
  }

  Future<VisitorModel> createVisitor(VisitorModel visitor) {
    return _apiService.createVisitor(visitor);
  }

  Future<VisitorModel> updateVisitor(VisitorModel visitor) {
    return _apiService.updateVisitor(visitor);
  }

  Future<VisitorModel> checkIn(String id) {
    return _apiService.checkIn(id);
  }

  Future<VisitorModel> checkOut(String id) {
    return _apiService.checkOut(id);
  }

  Future<void> deleteVisitor(String id) {
    return _apiService.deleteVisitor(id);
  }
}
