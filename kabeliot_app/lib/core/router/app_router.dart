import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_routes.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/devices/presentation/devices_screen.dart';
import '../../features/devices/presentation/add_device_screen.dart';
import '../../features/devices/presentation/provisioning_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/app_settings_screen.dart';
import '../../features/profile/presentation/notification_settings_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/devices/presentation/device_detail_screen.dart';
import '../../features/devices/domain/device_models.dart';
import '../../shared/providers/auth_state_provider.dart';
import '../../shared/widgets/main_shell.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final session = ref.watch(authStateProvider);
  final isAuthenticated = session != null;

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (location == AppRoutes.splash) return null;

      final authRoutes = [AppRoutes.login];
      final protectedRoutes = [AppRoutes.home, AppRoutes.devices, AppRoutes.notifications, AppRoutes.profile];

      if (!isAuthenticated && protectedRoutes.any((r) => location.startsWith(r))) {
        return AppRoutes.login;
      }
      if (isAuthenticated && authRoutes.contains(location)) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      // Auth akışı (shell dışı)
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),

      // Ana uygulama — StatefulShellRoute (bottom nav kalıcı)
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.home, builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.devices,
              builder: (_, __) => const DevicesScreen(),
              routes: [
                GoRoute(path: 'add', builder: (_, __) => const AddDeviceScreen()),
                GoRoute(path: 'provisioning', builder: (_, __) => const ProvisioningScreen()),
                GoRoute(
                  path: 'detail',
                  builder: (_, state) {
                    final device = state.extra as DeviceModel;
                    return DeviceDetailScreen(device: device);
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: AppRoutes.notifications, builder: (_, __) => const NotificationsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(path: 'notification-settings', builder: (_, __) => const NotificationSettingsScreen()),
                GoRoute(path: 'app-settings', builder: (_, __) => const AppSettingsScreen()),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
}
