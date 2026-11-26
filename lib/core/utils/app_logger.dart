import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class AppLogger {
  static const String _appTag = 'PraditaFind';

  static void info(String feature, String message) {
    developer.log(message, name: '$_appTag/INFO/$feature');
    debugPrint('[$_appTag][INFO][$feature] $message');
  }

  static void warn(String feature, String message, [Object? error]) {
    developer.log(message, name: '$_appTag/WARN/$feature', error: error);
    debugPrint(
      '[$_appTag][WARN][$feature] $message${error != null ? ' | $error' : ''}',
    );
  }

  static void error(
    String feature,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: '$_appTag/ERROR/$feature',
      error: error,
      stackTrace: stackTrace,
    );
    debugPrint(
      '[$_appTag][ERROR][$feature] $message${error != null ? ' | $error' : ''}',
    );
  }
}