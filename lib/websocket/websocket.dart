import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  late WebSocketChannel channel;
  final StreamController<String> _messageController = StreamController<String>.broadcast();

  factory WebSocketManager(){
    return _instance;
  }

  WebSocketManager._internal();

  void connect(String url){
    channel = WebSocketChannel.connect(Uri.parse(url));
    channel.stream.listen((data) {
      _messageController.add(data);
    });
  }


  void sendMessage(int opType,String group,String message){
    final msg = {
      "opType":opType,
      "group":group,
      "message":message
    };
    channel.sink.add(jsonEncode(msg));
  }

  Stream<String> get messageStream => _messageController.stream;

  void dispose(){
    channel.sink.close();
    _messageController.close();
  }




}