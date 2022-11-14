import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geotech_assignment/constrains.dart';
import 'package:geotech_assignment/providers/websocket_provider.dart';
import 'package:provider/provider.dart';

class Presets extends StatefulWidget {
  const Presets({Key? key}) : super(key: key);

  static const routeName = "/presets";

  @override
  State<Presets> createState() => _PresetsState();
}

class _PresetsState extends State<Presets> {
  late WebsocketProvider _websocketProvider;

  @override
  void initState() {
    _websocketProvider = Provider.of<WebsocketProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Presets"),
        backgroundColor: kForeground,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 350),
                        width: double.infinity,
                        height: kButtonHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(kCornerRadius),
                            color: kAccent,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Provider.of<WebsocketProvider>(
                                context,
                                listen: false,
                              ).refreshPresets();
                            },
                            child: const Text(
                              "Refresh",
                              style: TextStyle(color: kBackground),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const RemoteControlPresets(),
                    ],
                  ),
                ),
              ),
              const VerticalDivider(
                color: Colors.black,
                width: 20,
              ),
              const Expanded(
                child: ReceivedPresetEvents(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _websocketProvider.closeConnection();
    super.dispose();
  }
}

class RemoteControlPresets extends StatelessWidget {
// Used to build the list of presets from the engine
  const RemoteControlPresets({Key? key}) : super(key: key);

  void popCallback(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<WebsocketProvider>(context, listen: false)
          .presetsChannel
          .stream,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          popCallback(() {
            Navigator.pop(context);
          });
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(
            color: kAccent,
          );
        } else if (snapshot.hasData) {
          var response = jsonDecode(utf8.decode(snapshot.data!));
          if (response["ResponseCode"] == 200) {
            var responsePresets = response["ResponseBody"]!["Presets"];
            List<String> presets = [];
            for (var preset in responsePresets) {
              presets.add(preset["Name"]!);
            }
            Provider.of<WebsocketProvider>(context, listen: false).presets =
                presets;
          } else {
            /// If this were a production app, adding more specific error
            /// handling within the UI for each response code would increase
            /// usability and help the user with debugging
            log("Response code of ${response["ResponseCode"]} returned");
          }
          return Selector<WebsocketProvider, List<String>>(
            selector: (_, websocketProvider) => websocketProvider.presets,
            builder: (context, presets, _) {
              return (presets.isNotEmpty)
                  ? ListView.separated(
                      controller: ScrollController(),
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 5),
                      addAutomaticKeepAlives: false,
                      shrinkWrap: true,
                      itemCount: presets.length,
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 10,
                      ),
                      itemBuilder: (context, index) {
                        return PresetListTile(
                          index: index,
                          presets: presets,
                        );
                      },
                    )
                  : const Text(
                      "No presets set",
                      style: TextStyle(color: Colors.white),
                    );
            },
          );
        } else {
          return const Text(
            "No data available",
            style: TextStyle(color: Colors.white),
          );
        }
      },
    );
  }
}

class PresetListTile extends StatelessWidget {
  /// Used for building individual ListTiles to represent a preset
  const PresetListTile({
    Key? key,
    required this.index,
    required this.presets,
  }) : super(key: key);

  final int index;
  final List<String> presets;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        presets[index],
      ),
      trailing: const Icon(
        Icons.keyboard_arrow_right_rounded,
      ),
      textColor: Colors.white,
      iconColor: Colors.white,
      selectedColor: kAccent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCornerRadius)),
      selectedTileColor: kForeground,
      selected: index == Provider.of<WebsocketProvider>(context).selectedPreset,
      onTap: () {
        if (index ==
            Provider.of<WebsocketProvider>(context, listen: false)
                .selectedPreset) {
          Provider.of<WebsocketProvider>(
            context,
            listen: false,
          ).setSelectedPreset(null);
        } else {
          Provider.of<WebsocketProvider>(
            context,
            listen: false,
          ).setSelectedPreset(index);
        }
      },
    );
  }
}

class ReceivedPresetEvents extends StatelessWidget {
  /// Used to build the list of received preset events
  const ReceivedPresetEvents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<WebsocketProvider, List<Map<String, String>>>(
      selector: (_, websocketProvider) => websocketProvider.events,
      builder: (context, events, _) {
        return StreamBuilder(
          stream: Provider.of<WebsocketProvider>(context, listen: false)
              .eventsChannel
              .stream,
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {}
            if (snapshot.hasData) {
              var response = jsonDecode(utf8.decode(snapshot.data!));
              Provider.of<WebsocketProvider>(context, listen: false)
                  .events
                  .add({
                "Type": response["Type"],
                "PresetName":
                    response["PresetName"] ?? response["Preset"]["Name"]

                /// Assumption: i wasn't able to find any information in the UE
                /// documentation regarding PresetLayoutModified so I'm assuming
                /// that data is sent in either of the two forms above.
                /// Other JSON structures for this response
                /// would need to be handled accordingly if they were present
              });
              return ListView.builder(
                controller: ScrollController(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      events[index]["PresetName"]!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      events[index]["Type"]!,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  );
                },
              );
            } else {
              return const Text(
                "No preset events received",
                style: TextStyle(color: Colors.white),
              );
            }
          },
        );
      },
    );
  }
}
