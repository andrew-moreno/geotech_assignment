import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketProvider extends ChangeNotifier {
  /// Index of selected preset
  int? selectedPreset;

  /// List containing preset data from UE
  final List<String> presets = [];

  /// List containing event data from UE
  final List<Map<String, String>> events = [];

  // For managing websocket connection
  late WebSocketChannel _channel;
  final _streamController = StreamController.broadcast();

  /// Re populates [presets]
  void refreshPresets() {
    setSelectedPreset(null);
    presets.clear();
    getPresetNames();
    log("Presets refreshed");
    notifyListeners();
  }

  /// Sets [selectedPreset] to the provided index
  /// from the presets list and registers/unregisters
  /// presets accordingly
  ///
  /// If [index] = null, unregister the active preset
  ///
  /// Throws an error if index doesn't exist
  void setSelectedPreset(int? index) {
    if (selectedPreset != null) {
      _channel.sink.add(
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
      _channel.sink.add(
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
  void establishConnection(String websocketAddress) {
    _channel = WebSocketChannel.connect(Uri.parse(websocketAddress));
    _streamController.addStream(_channel.stream);

    log("Connecting to websocket address $websocketAddress");
  }

  /// Closes the connection to the active websocket
  /// and clears [presets] and [events]
  /// TODO: and pops context if on presets screen
  void closeConnection() {
    _channel.sink.close();
    presets.clear();
    events.clear();
    log("Websocket connection closed");
  }

  /// Gets the list of presets in the editor and adds them to the
  /// [presets] property
  Future<void> getPresetNames() async {
    _channel.sink.add(
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

    // For testing without Unreal Engine
    Map<String, dynamic> response = {
      "RequestId": -1,
      "ResponseCode": 200,
      "ResponseBody": {
        "Presets": [
          {"Name": "MyPreset1", "Path": "/Game/Presets/MyPreset.MyPreset"},
          {"Name": "MyPreset2", "Path": "/Game/Presets/MyPreset.MyPreset"},
          {"Name": "MyPreset3", "Path": "/Game/Presets/MyPreset.MyPreset"},
        ]
      }
    };
    if (response["ResponseCode"] == 200) {
      List<Map<String, String>> responsePresets =
          response["ResponseBody"]!["Presets"];
      for (var preset in responsePresets) {
        presets.add(preset["Name"]!);
      }
    } else {
      log("Response code of ${response["ResponseCode"]} returned");
    }
    // var streamSub = _streamController.stream.listen(
    //   (data) {
    //     var response = jsonDecode(data);
    //     if (response["ResponseCode"] == 200) {
    //       List<Map<String, String>> responsePresets =
    //           response["ResponseBody"]!["Presets"];
    //       for (var preset in responsePresets) {
    //         presets.add(preset["Name"]!);
    //       }
    //     } else {
    //       log("Response code of ${response["ResponseCode"]} returned");
    //     }
    //   },
    //   onError: (error) => log(error.toString()),
    // );
    // await streamSub.cancel();
    notifyListeners();
  }

  void getPresetEvents() {
    // For testing without Unreal Engine
    List<Map<String, dynamic>> testingEvents = [
      {
        "Type": "PresetFieldsChanged",
        "PresetName": "MyPreset",
        "ChangedFields": [
          {
            "PropertyLabel": "Relative Rotation (LightSource_0)",
            "ObjectPath":
                "/Game/ThirdPersonBP/Maps/ThirdPersonExampleMap.ThirdPersonExampleMap:PersistentLevel.LightSource_0.LightComponent0",
            "PropertyValue": {"Pitch": 14.4, "Yaw": 0, "Roll": 169.2}
          }
        ]
      },
      {
        "Type": "PresetFieldsAdded",
        "PresetName": "MyPreset",
        "Description": {
          "Name": "MyPreset",
          "Path": "/Game/Presets/MyPreset.MyPreset",
          "Groups": [
            {
              "Name": "Lighting",
              "ExposedProperties": [
                {
                  "DisplayName": "Light Color (LightSource_0)",
                  "UnderlyingProperty": {
                    "Name": "LightColor",
                  }
                }
              ],
              "ExposedFunctions": []
            }
          ]
        }
      }
    ];

    for (var event in testingEvents) {
      events.add({"Type": event["Type"], "PresetName": event["PresetName"]});
    }
    notifyListeners();

    // var streamSub = _streamController.stream.listen(
    //   (data) {
    //     events.add({"Type": data["Type"], "PresetName": data["PresetName"]});
    //     notifyListeners();
    // },
    //   onError: (error) => log(
    //     error.toString(),
    //   ),
    // );
  }
}
