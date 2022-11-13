import 'package:flutter/material.dart';
import 'package:geotech_assignment/constrains.dart';
import 'package:geotech_assignment/providers/websocket_provider.dart';
import 'package:provider/provider.dart';

class Presets extends StatefulWidget {
  const Presets({Key? key, required this.websocketAddress}) : super(key: key);

  static const routeName = "/presets";
  final String websocketAddress;

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
                      SizedBox(
                        width: double.infinity,
                        height: 40,
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
  /// Used to build the list of presets from the engine
  const RemoteControlPresets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<WebsocketProvider, List<String>>(
      selector: (_, websocketProvider) => websocketProvider.presets,
      builder: (context, presets, _) {
        return ListView.separated(
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
              selected: index ==
                  Provider.of<WebsocketProvider>(context).selectedPreset,
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
          },
        );
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
      },
    );
  }
}
