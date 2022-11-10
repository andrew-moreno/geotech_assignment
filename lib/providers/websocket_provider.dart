import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketProvider extends ChangeNotifier {
  /// Index of selected preset
  int? selectedPreset;

  late WebSocketChannel _channel;

  /// Refreshes the list of presets
  void refreshPresets() {
    selectedPreset = null;
    // TODO: reload presets list from /remote/presets endpoint
    log("Presets refreshed");
    notifyListeners();
  }

  /// Sets selectedPreset property to the provided index
  ///
  /// Throws an error if index doesn't exist
  void setSelectedPreset(int index) {
    // TODO: throw error if index doesn't exist
    selectedPreset = index;
    notifyListeners();
  }

  /// Establishes a websocket connection to the provided address
  void establishConnection(String websocketAddress) {
    _channel = WebSocketChannel.connect(Uri.parse(websocketAddress));
    log("Connecting to websocket address $websocketAddress");
  }

  /// Closes the connection to the active websocket
  void closeConnection() {
    _channel.sink.close();
  }
}
