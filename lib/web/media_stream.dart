import 'dart:async';
import 'dart:html' as HTML;

import 'package:flutter_webrtc/webrtc.dart';

class WebMediaStream extends MediaStream {
  final HTML.MediaStream jsStream;
  WebMediaStream(this.jsStream);

  Future<void> getMediaTracks() {
    return Future.value();
  }

  String get id => jsStream.id;
  Future<void> addTrack(MediaStreamTrack track, {bool addToNative = true}) {
    var webTrack = track as WebMediaStreamTrack;
    if (addToNative) {
      jsStream.addTrack(webTrack.jsTrack);
    }
    return Future.value();
  }

  Future<void> removeTrack(MediaStreamTrack track,
      {bool removeFromNative = true}) async {
    var webTrack = track as WebMediaStreamTrack;
    if (removeFromNative) {
      jsStream.removeTrack(webTrack.jsTrack);
    }
  }

  List<MediaStreamTrack> getAudioTracks() => jsStream
      .getAudioTracks()
      .map((jsTrack) => WebMediaStreamTrack(jsTrack))
      .toList();

  List<MediaStreamTrack> getVideoTracks() => jsStream
      .getVideoTracks()
      .map((jsTrack) => WebMediaStreamTrack(jsTrack))
      .toList();

  Future<Null> dispose() async {
    jsStream.getAudioTracks().forEach((track) => track.stop());
    jsStream.getVideoTracks().forEach((track) => track.stop());
  }

  @override
  void setMediaTracks(List<dynamic> audioTracks, List videoTracks) {
  }
}
