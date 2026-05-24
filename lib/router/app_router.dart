import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/landing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/marketplace_screen.dart';
import '../screens/sell_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/map_screen.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AppRouter {
  static GoRouter build(AuthProvider auth) => GoRouter(
        initialLocation: auth.isLoggedIn ? '/marketplace' : '/landing',
        redirect: (context, state) {
          final loggedIn = context.read<AuthProvider>().isLoggedIn;
          final protected = ['/sell', '/profile'];
          if (!loggedIn && protected.contains(state.matchedLocation)) {
            return '/login';
          }
          return null;
        },
        routes: [
          GoRoute(
            path: '/landing',
            builder: (_, __) => const LandingScreen(),
          ),
          GoRoute(
            path: '/login',
            builder: (_, __) => const LoginScreen(),
          ),
          GoRoute(
            path: '/register',
            builder: (_, __) => const RegisterScreen(),
          ),
          ShellRoute(
            builder: (context, state, child) => _MainShell(child: child),
            routes: [
              GoRoute(
                path: '/marketplace',
                builder: (_, __) => const MarketplaceScreen(),
              ),
              GoRoute(
                path: '/sell',
                builder: (_, __) => const SellScreen(),
              ),
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/chat',
            builder: (context, state) => ChatScreen(product: state.extra as Product),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) => MapScreen(product: state.extra as Product),
          ),
        ],
      );
}

class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  int _indexFor(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/sell')) return 1;
    if (loc.startsWith('/profile')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _indexFor(context);
    return Scaffold(
      backgroundColor: ecoDark,
      body: child,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            backgroundColor: ecoSurface,
            indicatorColor: ecoGreen.withValues(alpha: 0.2),
            selectedIndex: idx,
            onDestinationSelected: (i) {
              switch (i) {
                case 0:
                  context.go('/marketplace');
                case 1:
                  context.go('/sell');
                case 2:
                  context.go('/profile');
              }
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.store_outlined),
                selectedIcon: Icon(Icons.store, color: ecoGreenLight),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                selectedIcon: Icon(Icons.add_circle, color: ecoGreenLight),
                label: 'Sell',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: ecoGreenLight),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
