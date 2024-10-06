import 'dart:convert';

import 'package:chat_client/OpTypeConstants.dart';
import 'package:chat_client/websocket.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ChatPage extends StatefulWidget {
  final String group;

  ChatPage({super.key, required this.group});

  List<String> _messageList = [];

  late WebSocketManager webSocketManager;

  @override
  _ChatPageState createState() => _ChatPageState();
}


class _ChatPageState extends State<ChatPage> {
  final List<String> _messageList = [];
  late WebSocketManager _webSocketManager; // WebSocket 管理器实例
  late TextEditingController _controller;
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _webSocketManager = WebSocketManager();

    _webSocketManager.sendMessage(OpTypeConstants.JOIN_GROUP,widget.group,"");

    _webSocketManager.messageStream.listen((message){
      if(mounted) {
        setState(() {
          final jsonMessage = json.decode(message);
          final messageValue = jsonMessage['message'];
          _messageList.add(messageValue); // 本地添加消息到列表
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Page, group: ${widget.group}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messageList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messageList[index]),  // 显示消息
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,  // 绑定输入框控制器
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,  // 发送消息
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // 发送消息
  void _sendMessage() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      _webSocketManager.sendMessage(OpTypeConstants.SEND_MSG,widget.group, text);  // 发送消息到服务器
      _controller.clear();  // 清空输入框
    }
  }







}
