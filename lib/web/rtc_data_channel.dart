import 'dart:async';
import 'dart:html' as HTML;
import 'dart:js_util' as JSUtils;

import 'package:flutter_webrtc/webrtc.dart';

import '../enums.dart';

class WebRTCDataChannel extends RTCDataChannel {
  final HTML.RtcDataChannel _jsDc;
  RTCDataChannelStateCallback onDataChannelState;
  RTCDataChannelOnMessageCallback onMessage;
  RTCDataChannelState _state = RTCDataChannelState.RTCDataChannelConnecting;

  /// Get current state.
  RTCDataChannelState get state => _state;

  final _stateChangeController =
      StreamController<RTCDataChannelState>.broadcast(sync: true);
  final _messageController =
      StreamController<RTCDataChannelMessage>.broadcast(sync: true);

  /// Stream of state change events. Emits the new state on change.
  /// Closes when the [RTCDataChannel] is closed.
  Stream<RTCDataChannelState> stateChangeStream;

  /// Stream of incoming messages. Emits the message.
  /// Closes when the [RTCDataChannel] is closed.
  Stream<RTCDataChannelMessage> messageStream;

  WebRTCDataChannel(this._jsDc) {
    stateChangeStream = _stateChangeController.stream;
    messageStream = _messageController.stream;
    _jsDc.onClose.listen((_) {
      _state = RTCDataChannelState.RTCDataChannelClosed;
      _stateChangeController.add(_state);
      if (onDataChannelState != null) {
        onDataChannelState(_state);
      }
    });
    _jsDc.onOpen.listen((_) {
      _state = RTCDataChannelState.RTCDataChannelOpen;
      _stateChangeController.add(_state);
      if (onDataChannelState != null) {
        onDataChannelState(_state);
      }
    });
    _jsDc.onMessage.listen((event) async {
      RTCDataChannelMessage msg = await _parse(event.data);
      _messageController.add(msg);
      if (onMessage != null) {
        onMessage(msg);
      }
    });
  }

  Future<RTCDataChannelMessage> _parse(dynamic data) async {
    if (data is String) return RTCDataChannelMessage(data);
    dynamic arrayBuffer;
    if (data is HTML.Blob) {
      // This should never happen actually
      arrayBuffer = await JSUtils.promiseToFuture(
          JSUtils.callMethod(data, 'arrayBuffer', []));
    } else {
      arrayBuffer = data;
    }
    return RTCDataChannelMessage.fromBinary(arrayBuffer.asUint8List());
  }

  Future<void> send(RTCDataChannelMessage message) {
    if (!message.isBinary) {
      _jsDc.send(message.text);
    } else {
      // This may just work
      _jsDc.sendByteBuffer(message.binary.buffer);
      // If not, convert to ArrayBuffer/Blob
    }
    return Future.value();
  }

  Future<void> close() {
    _jsDc.close();
    return Future.value();
  }

  @override
  void errorListener(Object obj) {
  }

  @override
  void eventListener(Object obj) {
  }
}
