import 'package:flutter_webrtc/webrtc.dart';

abstract class MediaStream {
  String get id;

  Future<void> getMediaTracks();

  void setMediaTracks(List<dynamic> audioTracks, List<dynamic> videoTracks);

  Future<void> addTrack(MediaStreamTrack track, {bool addToNative = true});

  Future<void> removeTrack(MediaStreamTrack track, {bool removeFromNative = true});

  List<MediaStreamTrack> getAudioTracks();

  List<MediaStreamTrack> getVideoTracks();

  Future<Null> dispose();
}
