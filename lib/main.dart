import 'package:flutter/material.dart';
import 'package:geotech_assignment/constrains.dart';
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
          title: "Remote Control Test",
          theme: ThemeData(
            fontFamily: "Poppins",
            inputDecorationTheme: InputDecorationTheme(
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: kBackground,
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                disabledForegroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                backgroundColor: Colors.transparent,
              ),
            ),
            scaffoldBackgroundColor: kBackground,
          ),
          home: Connect(),
        );
      },
    );
  }
}
