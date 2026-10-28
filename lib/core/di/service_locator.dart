import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../features/visitors/viewmodels/visitor_view_model.dart';
import '../../repositories/visitor_repository.dart';
import '../../services/visitor_api_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  getIt.registerLazySingleton<VisitorApiService>(
    () => VisitorApiService(getIt<http.Client>()),
  );

  getIt.registerLazySingleton<VisitorRepository>(
    () => VisitorRepository(getIt<VisitorApiService>()),
  );

  getIt.registerFactory<VisitorViewModel>(
    () => VisitorViewModel(getIt<VisitorRepository>()),
  );
}
