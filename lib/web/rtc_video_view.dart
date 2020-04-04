import 'dart:async';
import 'dart:ui' as ui;
import 'dart:html' as HTML;
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/abstractions/rtc_video_view.dart';
import 'package:flutter_webrtc/webrtc.dart';

import '../enums.dart';

typedef void VideoRotationChangeCallback(int textureId, int rotation);
typedef void VideoSizeChangeCallback(
    int textureId, double width, double height);

class WebRTCVideoRenderer extends RTCVideoRenderer {
  double _width = 0.0, _height = 0.0;
  bool _mirror = false;
  MediaStream _srcObject;
  RTCVideoViewObjectFit _objectFit =
      RTCVideoViewObjectFit.RTCVideoViewObjectFitContain;
  VideoSizeChangeCallback onVideoSizeChanged;
  VideoRotationChangeCallback onVideoRotationChanged;
  dynamic onFirstFrameRendered;
  var isFirstFrameRendered = false;

  HtmlElementView htmlElementView;
  HTML.VideoElement _htmlVideoElement;

  static final _videoViews = List<HTML.VideoElement>();

  bool get isMuted => _htmlVideoElement?.muted ?? true;
  set isMuted(bool i) => _htmlVideoElement?.muted = i;

  static void fixVideoElements() => _videoViews.forEach((v) => v.play());

  WebRTCVideoRenderer(bool forceMute) : super.create(forceMute);

  Future<void> init() async {
  }

  int get rotation => 0;

  double get width => _width ?? 1080;

  double get height => _height ?? 1920;

  int get textureId => 0;

  double get aspectRatio =>
      (_width == 0 || _height == 0) ? (9 / 16) : _width / _height;

  bool get mirror => _mirror;

  set mirror(bool mirror) {
    _mirror = mirror;
    if (this.onStateChanged != null) {
      this.onStateChanged();
    }
  }

  RTCVideoViewObjectFit get objectFit => _objectFit;

  set objectFit(RTCVideoViewObjectFit objectFit) {
    _objectFit = objectFit;
    if (this.onStateChanged != null) {
      this.onStateChanged();
    }
  }

  set srcObject(MediaStream stream) {
    _srcObject = stream;
    var webStream = stream as WebMediaStream;

    if (_srcObject == null) {
      findHtmlView()?.srcObject = null;
      return;
    }

    if (htmlElementView != null) {
      findHtmlView()?.srcObject = webStream?.jsStream;
    }
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(stream.id, (int viewId) {
      final x = HTML.VideoElement();
      x.autoplay = true;
      x.muted = forceMute;
      x.srcObject = webStream.jsStream;
      _htmlVideoElement = x;
      _videoViews.add(x);
      return x;
    });
    htmlElementView = HtmlElementView(viewType: stream.id);
    if (this.onStateChanged != null) this.onStateChanged();
  }

  void findAndApply(Size size) {
    final htmlView = findHtmlView();
    var webStream = _srcObject as WebMediaStream;
    if (_srcObject != null && htmlView != null) {
      if (htmlView.width == size.width.toInt() &&
          htmlView.height == size.height.toInt()) return;
      htmlView.srcObject = webStream.jsStream;
      htmlView.width = size.width.toInt();
      htmlView.height = size.height.toInt();
      htmlView.onLoadedMetadata.listen((_) {
        if (htmlView.videoWidth != 0 &&
            htmlView.videoHeight != 0 &&
            (_width != htmlView.videoWidth ||
                _height != htmlView.videoHeight)) {
          _width = htmlView.videoWidth.toDouble();
          _height = htmlView.videoHeight.toDouble();
          if (onVideoSizeChanged != null)
            onVideoSizeChanged(0, _width, _height);
        }
        if (!isFirstFrameRendered && onFirstFrameRendered != null) {
          onFirstFrameRendered();
          isFirstFrameRendered = true;
        }
      });
      htmlView.onResize.listen((_) {
        if (htmlView.videoWidth != 0 &&
            htmlView.videoHeight != 0 &&
            (_width != htmlView.videoWidth ||
                _height != htmlView.videoHeight)) {
          _width = htmlView.videoWidth.toDouble();
          _height = htmlView.videoHeight.toDouble();
          if (onVideoSizeChanged != null)
            onVideoSizeChanged(0, _width, _height);
        }
      });
      if (htmlView.videoWidth != 0 &&
          htmlView.videoHeight != 0 &&
          (_width != htmlView.videoWidth || _height != htmlView.videoHeight)) {
        _width = htmlView.videoWidth.toDouble();
        _height = htmlView.videoHeight.toDouble();
        if (onVideoSizeChanged != null) onVideoSizeChanged(0, _width, _height);
      }
    }
  }

  HTML.VideoElement findHtmlView() {
    if (_htmlVideoElement != null) return _htmlVideoElement;
    final fltPv = HTML.document.getElementsByTagName('flt-platform-view');
    if (fltPv.isEmpty) return null;
    return (fltPv.first as HTML.Element).shadowRoot.lastChild;
  }

  Future<void> dispose() async {
    //TODO?
  }
}

class WebRTCVideoView extends RTCVideoView {
  WebRTCVideoView(RTCVideoRenderer renderer) : super.create(renderer);

  @override
  _RTCVideoViewState createState() => new _RTCVideoViewState(renderer);
}

class _RTCVideoViewState extends State<RTCVideoView> {
  final WebRTCVideoRenderer _renderer;
  double _aspectRatio;
  RTCVideoViewObjectFit _objectFit;
  bool _mirror;
  _RTCVideoViewState(this._renderer);

  @override
  void initState() {
    super.initState();
    _setCallbacks();
    _aspectRatio = _renderer.aspectRatio;
    _mirror = _renderer.mirror;
    _objectFit = _renderer.objectFit;
  }

  @override
  void dispose() {
    super.dispose();
    _renderer.onStateChanged = null;
  }

  void _setCallbacks() {
    _renderer.onStateChanged = () {
      setState(() {
        _aspectRatio = _renderer.aspectRatio;
        _mirror = _renderer.mirror;
        _objectFit = _renderer.objectFit;
      });
    };
  }

  Widget _buildVideoView(BoxConstraints constraints) {
    _renderer.findAndApply(constraints.biggest);
    return Container(
        width: constraints.maxWidth,
        height: constraints.maxHeight,
        child: new SizedBox(
            width: constraints.maxHeight * _aspectRatio,
            height: constraints.maxHeight,
            child: _renderer.htmlElementView ?? Container()));
  }

  @override
  Widget build(BuildContext context) {
    bool renderVideo = _renderer._srcObject != null;
    return new LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return new Center(
          child: renderVideo ? _buildVideoView(constraints) : new Container());
    });
  }
}
