import 'package:chat_flow/features/auth/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import '../../features/splash/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/chat/presentation/pages/users_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return _fadeRoute(const LoginPage());

      case '/register':
        return _fadeRoute(const RegisterPage());

      case '/users':
        return _slideRoute(const UsersPage());

      case '/profile':
        return _fadeRoute(const ProfilePage());

      case '/chat':
        final args = settings.arguments as Map;
        return _slideRoute(
          ChatPage(
            otherUid: args['uid'],
            otherUsername: args['username'],
          ),
        );

      default:
        return _fadeRoute(const SplashPage());
    }
  }

  // ---------------------------------------------------------
  // 🔥 Fade transition
  // ---------------------------------------------------------
  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, animation, _) => FadeTransition(
        opacity: animation,
        child: page,
      ),
    );
  }

  // ---------------------------------------------------------
  // 🔥 Slide transition
  // ---------------------------------------------------------
  static PageRouteBuilder _slideRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, animation, _) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0.15), 
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: page,
        );
      },
    );
  }
}
