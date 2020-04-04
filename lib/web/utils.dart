import 'package:flutter/services.dart';

class WebRTC {
  static MethodChannel methodChannel() => null;

  static bool get platformIsDesktop => false;

  static bool get platformIsMobile => false;

  static bool get platformIsWeb => true;
}
