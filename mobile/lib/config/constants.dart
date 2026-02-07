import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class AppConstants {
  static String get baseUrl {
    // kIsWeb must be checked first
    if (kIsWeb) {
      return 'http://localhost:3000';
    }
    // Now it's safe to check Platform
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static String get apiBaseUrl => '$baseUrl/api/v1';
  static String get toursImageUrl => '$baseUrl/img/tours';
  static String get usersImageUrl => '$baseUrl/img/users';
}
