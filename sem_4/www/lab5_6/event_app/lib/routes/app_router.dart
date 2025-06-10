import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:event_app/providers/auth_provider.dart';
import 'package:event_app/screens/auth_screen.dart';
import 'package:event_app/screens/home_screen.dart';
import 'package:event_app/screens/events_screen.dart';
import 'package:event_app/screens/event_details_screen.dart';
import 'package:event_app/screens/create_event_screen.dart';
import 'package:event_app/screens/users_screen.dart'; // Admin only
import 'package:event_app/screens/register_admin_screen.dart'; // Admin only

class AppRouter {
  static GoRouter getRouter(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final loggedIn = authProvider.isAuthenticated;
        final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

        if (!loggedIn && !loggingIn) {
          return '/login';
        }
        if (loggedIn && loggingIn) {
          return '/';
        }
        return null;
      },
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => AuthScreen(isLogin: true),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => AuthScreen(isLogin: false),
        ),
        GoRoute(
          path: '/events',
          builder: (context, state) => const EventsScreen(),
        ),
        GoRoute(
          path: '/events/create',
          builder: (context, state) => const CreateEventScreen(),
          redirect: (context, state) {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            if (!auth.isAuthenticated) {
              return '/login';
            }
            return null;
          },
        ),
        GoRoute(
          path: '/events/:eventId',
          builder: (context, state) => EventDetailsScreen(
            eventId: state.pathParameters['eventId']!,
          ),
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) => const UsersScreen(),
          redirect: (context, state) {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            if (!auth.isAuthenticated || !auth.isAdmin) {
              return '/'; // Redirect to home or login if not admin
            }
            return null;
          },
        ),
        GoRoute(
          path: '/register-admin',
          builder: (context, state) => const RegisterAdminScreen(),
          redirect: (context, state) {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            if (!auth.isAuthenticated || !auth.isAdmin) {
              return '/';
            }
            return null;
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Page not found: ${state.error}'),
        ),
      ),
    );
  }
}