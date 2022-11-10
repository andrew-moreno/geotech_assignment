import 'package:flutter/material.dart';
import 'package:geotech_assignment/providers/websocket_provider.dart';
import 'package:geotech_assignment/screens/connect.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WebsocketProvider(),
      builder: (context, child) {
        return MaterialApp(
          title: "GeoTech Assignment",
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              color: Colors.blue,
              shadowColor: Colors.black,
              elevation: 15,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.white),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
            scaffoldBackgroundColor: Colors.grey.shade900,
            textTheme: const TextTheme(),
          ),
          home: Connect(),
        );
      },
    );
  }
}
