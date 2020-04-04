import 'dart:typed_data';

import 'package:flutter_webrtc/enums.dart';

typedef void RTCDataChannelStateCallback(RTCDataChannelState state);
typedef void RTCDataChannelOnMessageCallback(RTCDataChannelMessage message);

final typeStringToMessageType = <String, MessageType>{
  'text': MessageType.text,
  'binary': MessageType.binary
};

final messageTypeToTypeString = <MessageType, String>{
  MessageType.text: 'text',
  MessageType.binary: 'binary'
};

class RTCDataChannelInit {
  bool ordered = true;
  int maxRetransmitTime = -1;
  int maxRetransmits = -1;
  String protocol = 'sctp'; //sctp | quic
  String binaryType = 'text'; // "binary" || text
  bool negotiated = false;
  int id = 0;
  Map<String, dynamic> toMap() {
    return {
      'ordered': ordered,
      if (maxRetransmitTime > 0)
      //https://www.chromestatus.com/features/5198350873788416
        'maxPacketLifeTime': maxRetransmitTime,
      if (maxRetransmits > 0) 'maxRetransmits': maxRetransmits,
      'protocol': protocol,
      'negotiated': negotiated,
      if (id != 0) 'id': id
    };
  }
}

/// A class that represents a datachannel message.
/// Can either contain binary data as a [Uint8List] or
/// text data as a [String].
class RTCDataChannelMessage {
  dynamic _data;
  bool _isBinary;

  /// Construct a text message with a [String].
  RTCDataChannelMessage(String text) {
    this._data = text;
    this._isBinary = false;
  }

  /// Construct a binary message with a [Uint8List].
  RTCDataChannelMessage.fromBinary(Uint8List binary) {
    this._data = binary;
    this._isBinary = true;
  }

  /// Tells whether this message contains binary.
  /// If this is false, it's a text message.
  bool get isBinary => _isBinary;

  MessageType get type => isBinary ? MessageType.binary : MessageType.text;

  /// Text contents of this message as [String].
  /// Use only on text messages.
  /// See: [isBinary].
  String get text => _data;

  /// Binary contents of this message as [Uint8List].
  /// Use only on binary messages.
  /// See: [isBinary].
  Uint8List get binary => _data;
}

abstract class RTCDataChannel {
  /// Get current state.
  RTCDataChannelState get state;

  /// Event handler for datachannel state changes.
  /// Assign this property to listen for state changes.
  /// Will be passed one argument, [state], which is an [RTCDataChannelState].
  RTCDataChannelStateCallback onDataChannelState;

  /// Event handler for messages. Assign this property
  /// to listen for messages from this [RTCDataChannel].
  /// Will be passed a a [message] argument, which is an [RTCDataChannelMessage] that will contain either
  /// binary data as a [Uint8List] or text data as a [String].
  RTCDataChannelOnMessageCallback onMessage;

  /// Stream of state change events. Emits the new state on change.
  /// Closes when the [RTCDataChannel] is closed.
  Stream<RTCDataChannelState> stateChangeStream;

  /// Stream of incoming messages. Emits the message.
  /// Closes when the [RTCDataChannel] is closed.
  Stream<RTCDataChannelMessage> messageStream;

  /// RTCDataChannel event listener.
  void eventListener(dynamic event);

  void errorListener(Object obj);

  /// Send a message to this datachannel.
  /// To send a text message, use the default constructor to instantiate a text [RTCDataChannelMessage]
  /// for the [message] parameter.
  /// To send a binary message, pass a binary [RTCDataChannelMessage]
  /// constructed with [RTCDataChannelMessage.fromBinary]
  Future<void> send(RTCDataChannelMessage message);

  Future<void> close();
}