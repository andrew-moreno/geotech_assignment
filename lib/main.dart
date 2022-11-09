import 'package:flutter/material.dart';
import 'package:geotech_assignment/screens/connect.dart';
import 'package:geotech_assignment/screens/presets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GeoTech Assignment",
      theme: ThemeData(),
      home: const Connect(),
      routes: {
        Presets.routeName: (ctx) => const Presets(),
      },
    );
  }
}
