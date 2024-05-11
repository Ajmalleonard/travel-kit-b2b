import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  /// Production backend. Override with --dart-define for local dev:
  ///   flutter run --dart-define=TWENDE_BACKEND_URL=http://192.168.x.x:8090/api/v1
  static const String _productionUrl =
      'https://api.travelengine.zhio.dev/api/v1';

  static String get backendBaseUrl {
    const override = String.fromEnvironment('TWENDE_BACKEND_URL');
    if (override.isNotEmpty) return override;
    return _productionUrl;
  }

  /// Toggle to false to force real auth even in dev. Defaults to true so the
  /// app boots into a preview session without a working backend.
  static const bool devBypassAuth = bool.fromEnvironment(
    'DEV_BYPASS_AUTH',
    defaultValue: kDebugMode,
  );
}
// 临时解决，别改动 - 20659