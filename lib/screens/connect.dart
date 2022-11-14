import 'dart:developer';

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

  static const containerPadding = 20.0;
  static const textFieldMaxWidth = 350.0;

  @override
  Widget build(BuildContext context) {
    bool invalidAddress = false;
    return Scaffold(
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(containerPadding),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(kCornerRadius),
                      topRight: Radius.circular(kCornerRadius),
                    ),
                    color: kForeground,
                  ),
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
                        constraints:
                            const BoxConstraints(maxWidth: textFieldMaxWidth),
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
                            } else if (invalidAddress) {
                              invalidAddress = false;
                              return "Please enter a valid Websocket Address";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: textFieldMaxWidth + containerPadding * 2,
                  height: kButtonHeight,
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

                        try {
                          Provider.of<WebsocketProvider>(context, listen: false)
                              .establishConnection(_controller.text);
                        } catch (e) {
                          log("Invalid websocket address");
                          invalidAddress = true;
                          _formKey.currentState!.validate();
                          return;
                        }
                        Provider.of<WebsocketProvider>(context, listen: false)
                            .getPresetNames();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: ((context) => const Presets()),
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
      ),
    );
  }
}
