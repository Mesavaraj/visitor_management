import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/dashboard/view/dashboard_screen.dart';
import '../../features/qr_scanner/view/qr_scanner_screen.dart';
import '../../features/visitors/view/visitor_details_screen.dart';
import '../../features/visitors/view/visitor_form_screen.dart';
import '../../features/visitors/view/visitor_list_screen.dart';
import '../../features/visitors/viewmodels/visitor_view_model.dart';
import '../../models/visitor_model.dart';
import '../../widgets/bottom_navigation_widget.dart';

final GoRouter router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return BottomNavigationWidget(navigationShell: navigationShell);
      },
      branches: [
        // Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) {
                final vm = context.watch<VisitorViewModel>();

                return DashboardScreen(
                  visitors: vm.visitors,
                  isLoading: vm.isLoading,
                  errorMessage: vm.errorMessage,
                  onRefresh: vm.loadVisitors,
                  onRegisterVisitor: () => context.push('/visitor-form'),
                  onViewVisitors: () => context.go('/visitors'),
                  onScanQr: () => context.go('/scan'),
                );
              },
            ),
          ],
        ),

        // Visitor list
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/visitors',
              builder: (context, state) {
                return VisitorListScreen(
                  onOpenDetails: (visitor) {
                    context.push('/visitor-details', extra: visitor);
                  },
                  onEditVisitor: (visitor) {
                    context.push('/visitor-form', extra: visitor);
                  },
                  onRegisterVisitor: () {
                    context.push('/visitor-form');
                  },
                );
              },
            ),
          ],
        ),

        // QR scanner
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scan',
              builder: (context, state) => const QrScannerScreen(),
            ),
          ],
        ),
      ],
    ),

    // Registration and editing
    GoRoute(
      path: '/visitor-form',
      builder: (context, state) {
        final visitor = state.extra as VisitorModel?;

        return VisitorFormScreen(visitor: visitor);
      },
    ),

    // Visitor details
    GoRoute(
      path: '/visitor-details',
      builder: (context, state) {
        final visitor = state.extra as VisitorModel?;

        if (visitor == null) {
          return const Scaffold(
            body: Center(child: Text('Visitor information is missing.')),
          );
        }

        return VisitorDetailsScreen(visitor: visitor);
      },
    ),
  ],
);
