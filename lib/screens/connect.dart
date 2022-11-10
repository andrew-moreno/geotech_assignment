import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const Text("Flutter Remote Control Test"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      Provider.of<WebsocketProvider>(context, listen: false)
                          .establishConnection(_controller.text);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: ((context) => Presets(
                                websocketAddress: _controller.text,
                              )),
                        ),
                      );
                    },
                    child: const Text("Connect"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
