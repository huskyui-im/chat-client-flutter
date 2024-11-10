import 'package:chat_client/screens/login_page.dart';
import 'package:chat_client/storage/hive_storage.dart';
import 'package:flutter/material.dart';

void main() {
  initHive();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }

  const MyApp();
}




