import 'dart:convert';

import 'package:chat_client/constants/op_type_constants.dart';
import 'package:chat_client/screens/message_bubble.dart';
import 'package:chat_client/websocket/websocket.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import '../constants/config_constants.dart';

import 'package:http/http.dart' as http;

import '../model/message.dart';
import '../storage/hive_storage.dart';

class ChatPage extends StatefulWidget {
  final String group;

  ChatPage({super.key, required this.group});

  late WebSocketManager webSocketManager;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messageList = [];
  late WebSocketManager _webSocketManager; // WebSocket 管理器实例
  late TextEditingController _controller;
  final Logger logger = Logger();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  late String currentUser = "";

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _webSocketManager = WebSocketManager();

    _webSocketManager.sendMessage(OpTypeConstants.JOIN_GROUP, widget.group, "");

    _webSocketManager.messageStream.listen((message) {
      if (mounted) {
        setState(() {
          final jsonMessage = json.decode(message);
          var messageModel = Message.fromJson(jsonMessage);
          _messageList.add(messageModel); // 本地添加消息到列表
        });
      }
    });

    fetchCurrentUser();
  }

  // 异步辅助方法
  Future<void> fetchCurrentUser() async {
    String user = await getCurrentUser();
    if (mounted) {
      setState(() {
        currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messageList.length,
              itemBuilder: (context, index) {
                Message message = _messageList[index];
                return MessageBubble(
                  message: message,
                  currentUser: currentUser,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: _controller, // 绑定输入框控制器,
                      decoration: InputDecoration(
                          hintText: "请输入消息",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onSubmitted: (_){
                        _sendMessage();
                      },
                      maxLines: null,
                    )),
                    const SizedBox(width: 10),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _sendMessage,
                      child: const Text("发送"), // 发送消息
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                        onPressed: _showBottomSheet,
                        icon: const Icon(Icons.add_sharp))
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
      await uploadImage(image);
    }
  }

  Future<void> uploadImage(XFile image) async {
    String url = "http://$ip:8080/upload/image";
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));

      // 读取文件并创建 multipart 文件对象
      var bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'upload.jpg',
      ));

      var response = await request.send();
      print(response);
      if (response.statusCode == 200) {
        final data = jsonDecode(await response.stream.bytesToString());
        final imgUrl = data['data'];
        _webSocketManager.sendMessage(
            OpTypeConstants.SEND_IMAGE, widget.group, "$image_prefix$imgUrl");
      } else {
        print("图片上传失败：${response.statusCode}");
      }
    } catch (e) {
      print("上传出错：$e");
    }
  }

  // 发送消息
  void _sendMessage() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      _webSocketManager.sendMessage(
          OpTypeConstants.SEND_MSG, widget.group, text); // 发送消息到服务器
      _controller.clear(); // 清空输入框
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              ListTile(
              leading: const Icon(Icons.upload),
                title: Text("选择图片"),
                onTap: (){
                  Navigator.pop(context);
                  _pickImage();
                },
              )
            ],
          );
        });
  }
}
