import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/terminal_lab/presentation/terminal_lab_screen.dart';

CustomTransitionPage<T> _buildSpatialTransition<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 340),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final slideTween = Tween<Offset>(
        begin: const Offset(0.0, 0.045),
        end: Offset.zero,
      ).animate(curved);

      final scaleTween = Tween<double>(
        begin: 0.96,
        end: 1.0,
      ).animate(curved);

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: scaleTween,
          child: SlideTransition(
            position: slideTween,
            child: child,
          ),
        ),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildSpatialTransition(
        state: state,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/auth',
      pageBuilder: (context, state) => _buildSpatialTransition(
        state: state,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _buildSpatialTransition(
        state: state,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/terminal-lab',
      pageBuilder: (context, state) => _buildSpatialTransition(
        state: state,
        child: const TerminalLabScreen(),
      ),
    ),
    GoRoute(
      path: '/chat',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return _buildSpatialTransition(
          state: state,
          child: ChatScreen(
            specializationTitle: extra?['title'] as String? ?? 'محادثة عامة',
            specializationSubtitle:
                extra?['subtitle'] as String? ?? 'استشارة حرة لأي فكرة',
            accentColor: extra?['accentColor'] as Color?,
            starterPrompts: (extra?['starterPrompts'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList(),
          ),
        );
      },
    ),
  ],
);
