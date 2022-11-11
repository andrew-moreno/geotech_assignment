import 'package:flutter/material.dart';
import 'package:geotech_assignment/providers/websocket_provider.dart';
import 'package:provider/provider.dart';

class Presets extends StatefulWidget {
  const Presets({
    Key? key,
    required this.websocketAddress,
  }) : super(key: key);

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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<WebsocketProvider>(
                            context,
                            listen: false,
                          ).refreshPresets();
                        },
                        child: const Text("Refresh"),
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
    return ListView.separated(
      controller: ScrollController(),
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 5),
      addAutomaticKeepAlives: false,
      shrinkWrap: true,
      itemCount: 3,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            "RCP_$index",
          ),
          trailing: const Icon(
            Icons.arrow_right_rounded,
          ),
          textColor: Colors.white,
          iconColor: Colors.white,
          selectedColor: Colors.blue,
          selectedTileColor: Colors.grey.shade800,
          selected:
              index == Provider.of<WebsocketProvider>(context).selectedPreset,
          onTap: () {
            Provider.of<WebsocketProvider>(
              context,
              listen: false,
            ).setSelectedPreset(index);
          },
        );
      },
    );
  }
}

class ReceivedPresetEvents extends StatelessWidget {
  /// Used to build the list of received preset events
  const ReceivedPresetEvents({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<WebsocketProvider>(
      builder: (context, websocketProvider, _) {
        return ListView.builder(
          controller: ScrollController(),
          itemCount: (websocketProvider.selectedPreset != null) ? 3 : 0,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                "RCP_${websocketProvider.selectedPreset}",
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "subtitle",
                style: TextStyle(color: Colors.grey.shade500),
              ),
            );
          },
        );
      },
    );
  }
}
