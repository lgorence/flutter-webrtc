import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/webrtc.dart';

typedef void OnStateChanged();

abstract class RTCVideoRenderer {
  final bool forceMute;

  OnStateChanged onStateChanged;

  RTCVideoRenderer.create(this.forceMute);

  factory RTCVideoRenderer({forceMute = false}) {
    if (WebRTC.platformIsWeb) {
      return WebRTCVideoRenderer(forceMute);
    } else {
      return NativeRTCVideoRenderer(forceMute);
    }
  }

  bool get isMuted;
  set isMuted(bool muted);

  set srcObject(MediaStream mediaStream);
  int get rotation;
  double get width;
  double get height;
  int get textureId;
  double get aspectRatio;
  bool get mirror;
  set mirror(bool mirror);

  Future<void> init();
  Future<void> dispose();
}

abstract class RTCVideoView extends StatefulWidget {
  final RTCVideoRenderer renderer;
  RTCVideoView.create(this.renderer, {Key key}) : super(key: key);

  factory RTCVideoView(RTCVideoRenderer renderer) {
    if (WebRTC.platformIsWeb) {
      return WebRTCVideoView(renderer);
    } else {
      return NativeRTCVideoView(renderer);
    }
  }
}
