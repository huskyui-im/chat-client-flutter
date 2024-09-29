import 'package:chat_client/websocket.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


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
    } else {
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
    WebSocketManager().connect('ws://127.0.0.1:8888/ws?token=${widget.token}');
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 切换群组
  void _switchGroup(String group) {
    _toastMsg('选择群组$group');
    setState(() {
      _currentGroup = group;
      _messages = _groupMessages[group]!;
    });
  }

  void _toastMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg),
          duration: Duration(seconds: 2),));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("群组"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 群组切换按钮
            Expanded(
                child: ListView.builder(
                  itemCount: _groupMessages.length,
                  itemBuilder: (context, index) {
                    String group = _groupMessages.keys.elementAt(index);
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          group,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () => _switchGroup(group),
                      ),
                    );
                  },
                )
            ),
          ],
        ),
      ),
    );
  }
}