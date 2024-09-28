import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _token;

  // 登录请求
  Future<void> _login() async {
    final tokenText = _usernameController.text;
    final token = tokenText;

    setState(() {
      _isLoading = true;
    });


    setState(() {
      _isLoading = false;
    });

    if (token != '') {
      setState(() {
        _token = token;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MultiGroupChatPage(token: _token!)),
      );
    }else{
      _showError("请输入用户信息");
    }

  }

  // 显示错误信息
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Token'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                  onPressed: _login, child: Text('Login')),
            ],
          ),
        ),
      ),
    );
  }
}

class MultiGroupChatPage extends StatefulWidget {
  final String token;

  MultiGroupChatPage({required this.token});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<MultiGroupChatPage> {
  late WebSocketChannel _channel;
  final TextEditingController _messageController = TextEditingController();
  List<String> _messages = [];
  String _currentGroup = 'group1'; // 默认群组
  Map<String, List<String>> _groupMessages = {
    'group1': [],
    'group2': [],
    'group3': [],
  };

  @override
  void initState() {
    super.initState();

    // 使用获取到的 token 连接 WebSocket
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://192.168.3.4:8888/ws?token=${widget.token}'),
    );

    // 监听 WebSocket 消息
    _channel.stream.listen((message) {
      final data = json.decode(message);
      String group = data['group'];
      String msg = data['msg'];
      if (_groupMessages.containsKey(group)) {
        setState(() {
          _groupMessages[group]!.add(msg);
        });
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  // 发送消息
  void _sendMessage() {
    String msg = _messageController.text;
    if (msg.isNotEmpty) {
      final data = {
        'group': _currentGroup,
        'msg':msg
      };

      _channel.sink.add(json.encode(data));
      _messageController.clear();
    }
  }

  // 切换群组
  void _switchGroup(String group) {
    setState(() {
      _currentGroup = group;
      _messages = _groupMessages[group]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi-Group Chat'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 群组切换按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _switchGroup('group1'),
                  child: Text('Group 1'),
                ),
                ElevatedButton(
                  onPressed: () => _switchGroup('group2'),
                  child: Text('Group 2'),
                ),
                ElevatedButton(
                  onPressed: () => _switchGroup('group3'),
                  child: Text('Group 3'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Current Group: $_currentGroup', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_messages[index]),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Send a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}