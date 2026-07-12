import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/customer_display/presentation/customer_display_page.dart';
import '../features/display/kitchen_display_screen.dart';
import '../features/pairing/pairing_screen.dart';
import '../features/pos/order_preview_screen.dart';
import '../features/pos/pos_shell_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/terminal/terminal_selection_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: SplashScreen.routePath,
    routes: [
      GoRoute(
        path: SplashScreen.routePath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: PairingScreen.routePath,
        builder: (context, state) => const PairingScreen(),
      ),
      GoRoute(
        path: LoginScreen.routePath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: TerminalSelectionScreen.routePath,
        builder: (context, state) => const TerminalSelectionScreen(),
      ),
      GoRoute(
        path: PosShellScreen.routePath,
        builder: (context, state) => const PosShellScreen(),
      ),
      GoRoute(
        path: KitchenDisplayScreen.routePath,
        builder: (context, state) => const KitchenDisplayScreen(),
      ),
      GoRoute(
        path: CustomerDisplayPage.routePath,
        builder: (context, state) => const CustomerDisplayPage(),
      ),
      GoRoute(
        path: OrderPreviewScreen.routePath,
        pageBuilder: (context, state) {
          final data = state.extra;
          if (data is! OrderPreviewData) {
            return const MaterialPage(child: PosShellScreen());
          }
          return CustomTransitionPage<OrderPreviewResult>(
            child: OrderPreviewScreen(data: data),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(curved),
                      child: child,
                    ),
                  );
                },
          );
        },
      ),
    ],
  );
});
