/// Uygulama rota sabitleri
abstract final class AppRoutes {
  // Auth akışı (shell dışı)
  static const String splash = '/';
  static const String login = '/login';

  // Ana ekranlar (shell içi — bottom nav)
  static const String home = '/home';
  static const String devices = '/devices';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Alt ekranlar
  static const String addDevice = '/devices/add';
  static const String settings = '/profile/settings';
  static const String deviceDetail = '/devices/detail';
}
