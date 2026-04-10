import 'package:flutter/foundation.dart';

class AppLog {
  static void info(String msg) {
    if (kDebugMode) debugPrint("INFO: $msg");
  }

  static void error(String msg, [dynamic error]) {
    if (kDebugMode) {
      debugPrint("ERROR: $msg");
      if (error != null) debugPrint("Detail: $error");
    }
  }

  static void warning(dynamic e) {
    if (kDebugMode) debugPrint("WARNING: $e");
  }
}
