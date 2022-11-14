import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketProvider extends ChangeNotifier {
  /// Index of selected preset
  int? selectedPreset;

  /// List containing preset data from UE
  List<String> presets = [];

  /// List containing event data from UE
  final List<Map<String, String>> events = [];

  // For managing websocket connection
  late WebSocketChannel presetsChannel;
  late WebSocketChannel eventsChannel;

  /// Re populates [presets]
  void refreshPresets() {
    setSelectedPreset(null);
    getPresetNames();
    log("Presets refreshed");
  }

  /// Sets [selectedPreset] to the provided index
  /// from the presets list and registers/unregisters
  /// presets accordingly
  ///
  /// Throws an error if index doesn't exist
  void setSelectedPreset(int? index) {
    if (selectedPreset == index) {
      return;
    }
    if (selectedPreset != null) {
      eventsChannel.sink.add(
        jsonEncode(
          {
            "MessageName": "preset.unregister",
            "Parameters": {"PresetName": presets[selectedPreset!]}
          },
        ),
      );
      log("${presets[selectedPreset!]} unregistered");
    }
    selectedPreset = index;
    if (selectedPreset != null) {
      if (selectedPreset! > presets.length - 1) {
        throw RangeError("Index out of range of presets list");
      }
      eventsChannel.sink.add(
        jsonEncode(
          {
            "MessageName": "preset.register",
            "Parameters": {"PresetName": presets[selectedPreset!]}
          },
        ),
      );
      log("${presets[selectedPreset!]} registered");
    }
    notifyListeners();
  }

  /// Establishes a websocket connection to the provided address
  ///
  /// If this were a full production application, websocket connections would
  /// need to be authenticated to prevent malicious attacks on the application
  void establishConnection(String websocketAddress) {
    presetsChannel = WebSocketChannel.connect(Uri.parse(websocketAddress));
    eventsChannel = WebSocketChannel.connect(Uri.parse(websocketAddress));
    log("Connecting to websocket address $websocketAddress");
  }

  /// Closes the connection to the active websocket
  /// and clears [presets] and [events]
  void closeConnection() {
    presetsChannel.sink.close();
    eventsChannel.sink.close();
    presets.clear();
    events.clear();
    log("Connection closed to preset and events listener.");
  }

  /// Gets the list of presets in the editor and adds them to the
  /// [presets] property
  void getPresetNames() {
    presetsChannel.sink.add(
      jsonEncode(
        {
          "MessageName": "http",
          "Parameters": {
            "Url": "/remote/presets",
            "Verb": "GET",
            "Body": {},
          }
        },
      ),
    );
    log("GET request sent to /remote/presets");
  }
}
