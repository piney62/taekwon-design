import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void debug(Object? message, {String? tag}) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[${tag ?? 'app'}] $message');
    }
  }

  static void error(Object? message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('[ERROR] $message');
      if (error != null) {
        // ignore: avoid_print
        print('  cause: $error');
      }
      if (stackTrace != null) {
        // ignore: avoid_print
        print(stackTrace);
      }
    }
  }
}
