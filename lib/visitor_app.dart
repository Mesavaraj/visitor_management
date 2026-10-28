import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visitor_management/core/di/service_locator.dart';
import 'package:visitor_management/core/router/app_router.dart';
import 'package:visitor_management/features/visitors/viewmodels/visitor_view_model.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VisitorViewModel>(
      create: (_) => getIt<VisitorViewModel>()..loadVisitors(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Visitor Management',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3867E8)),
        ),
        routerConfig: router,
      ),
    );
  }
}
