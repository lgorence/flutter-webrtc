import 'dart:async';
import 'dart:js' as JS;
import 'dart:html' as HTML;

import 'package:flutter_webrtc/webrtc.dart';

import '../enums.dart';

class MediaRecorder {
  String filePath;
  HTML.MediaRecorder _recorder;
  List<HTML.Blob> _chunks;
  Completer<dynamic> _completer;

  /// For Android use audioChannel param
  /// For iOS use audioTrack
  Future<void> start(
    String path, {
    MediaStreamTrack videoTrack,
    MediaStreamTrack audioTrack,
    RecorderAudioChannel audioChannel,
    int rotation,
  }) {
    throw "Use startWeb on Flutter Web!";
  }

  /// Only for Flutter Web
  startWeb(MediaStream stream,
      {Function(dynamic blob, bool isLastOne) onDataChunk,
      String mimeType = 'video/webm'}) {
    var webStream = stream as WebMediaStream;

    _recorder = HTML.MediaRecorder(webStream.jsStream, {'mimeType': mimeType});
    if (onDataChunk == null) {
      _chunks = List();
      _completer = Completer();
      _recorder.addEventListener('dataavailable', (HTML.Event event) {
        final HTML.Blob blob = JS.JsObject.fromBrowserObject(event)['data'];
        if (blob.size > 0) {
          _chunks.add(blob);
        }
        if (_recorder.state == 'inactive') {
          final blob = HTML.Blob(_chunks, mimeType);
          _completer?.complete(HTML.Url.createObjectUrlFromBlob(blob));
          _completer = null;
        }
      });
      _recorder.onError.listen((error) {
        _completer?.completeError(error);
        _completer = null;
      });
    } else {
      _recorder.addEventListener('dataavailable', (HTML.Event event) {
        final HTML.Blob blob = JS.JsObject.fromBrowserObject(event)['data'];
        onDataChunk(blob, _recorder.state == 'inactive');
      });
    }
    _recorder.start();
  }

  Future<dynamic> stop() {
    _recorder?.stop();
    return _completer?.future ?? Future.value();
  }
}
