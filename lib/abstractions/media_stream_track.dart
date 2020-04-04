abstract class MediaStreamTrack {
  bool get enabled;
  String get label;
  String get kind;
  String get id;

  set enabled(bool enabled);

  Future<bool> hasTorch();
  Future<void> setTorch(bool torch);
  Future<bool> switchCamera();
  Future<void> dispose();

  void setVolume(double volume);
  void setMicrophoneMute(bool mute);
  void enableSpeakerphone(bool enable);
  captureFrame([String filePath]);
}
