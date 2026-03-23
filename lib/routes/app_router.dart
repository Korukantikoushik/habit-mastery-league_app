import 'package:go_router/go_router.dart';

import '../features/habits/presentation/screens/habit_detail_screen.dart';
import '../features/navigation/presentation/screens/main_navigation_screen.dart'; // ✅ FIXED
import '../features/settings/presentation/screens/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/habit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return HabitDetailScreen(habitId: id);
      },
    ),
  ],
);
