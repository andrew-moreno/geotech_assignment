import 'package:flutter/material.dart';
import 'package:geotech_assignment/constrains.dart';
import 'package:geotech_assignment/providers/websocket_provider.dart';
import 'package:geotech_assignment/screens/presets.dart';
import 'package:provider/provider.dart';

class Connect extends StatelessWidget {
  Connect({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller =
      TextEditingController(text: "ws://127.0.0.1:30020");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(kCornerRadius),
                    topRight: Radius.circular(kCornerRadius),
                  ),
                  color: kForeground,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Flutter Remote Control Test",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: TextFormField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          autofocus: true,
                          decoration: const InputDecoration(
                            labelText: "Websocket Address",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a Websocket address";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 390,
                height: 40,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(kCornerRadius),
                      bottomRight: Radius.circular(kCornerRadius),
                    ),
                    color: kAccent,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      Provider.of<WebsocketProvider>(context, listen: false)
                          .establishConnection(_controller.text);
                      Provider.of<WebsocketProvider>(context, listen: false)
                          .getPresetNames();
                      Provider.of<WebsocketProvider>(context, listen: false)
                          .getPresetEvents();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: ((context) => Presets(
                                websocketAddress: _controller.text,
                              )),
                        ),
                      );
                    },
                    child: const Text(
                      "Connect",
                      style: TextStyle(color: kBackground),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
