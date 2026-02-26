import 'package:flutter/foundation.dart';

class AppConfig {
  // Spring Boot base endpoint
  static const String apiPath = "/api/v1/words";

  // Web (Chrome): backend is usually http://localhost:8080
  static const String webBase = "http://localhost:8080$apiPath";

  // Android Emulator: must use 10.0.2.2 to access host machine
  static const String androidEmulatorBase = "http://10.0.2.2:8080$apiPath";

  // Desktop (Windows/macOS/Linux) usually can use 127.0.0.1
  static const String desktopBase = "http://127.0.0.1:8080$apiPath";

  static String get baseUrl {
    if (kIsWeb) return webBase;
    return androidEmulatorBase; // change to desktopBase if you're running desktop app
  }
}