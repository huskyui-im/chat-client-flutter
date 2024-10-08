import 'package:chat_client/CreateGroup.dart';
import 'package:chat_client/websocket.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:logger/logger.dart';

import 'ChatPage.dart';

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
  final logger = Logger();

  // 登录请求

  Future<void> _login() async {
    final username = _usernameController.text;
    if (username.isEmpty) {
      _showError("请输入用户名");
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse("http://192.168.3.4:8080/auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );
      logger.d(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['data'];
        setState(() {
          _token = token;
        });
        _showError("登录成功$token");
      } else {
        _showError("登录失败");
      }

      //
      //
      //

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MultiGroupChatPage(token: _token!)),
      );
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                  : ElevatedButton(onPressed: _login, child: Text('Login')),
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
   List<String> _groupMessages = [];

   final logger = Logger();

  @override
  void initState() {
    super.initState();
    // init webSocket instance
    WebSocketManager().connect('ws://192.168.3.4:8888/ws?token=${widget.token}');
    // fetch group list
    _fetchGroupList();
  }
   // 登录请求

  @override
  void dispose() {
    super.dispose();
  }

  // 切换群组
  void _switchGroup(String group) {
    // 导航到聊天页面
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChatPage(
                group: group,
              )),
    );
  }

  void _createGroup(){
    // 导航到聊天页面
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateGroupWidget()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("群组"),
          actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
           _createGroup();
          },
        )
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 群组切换按钮
            Expanded(
                child: ListView.builder(
              itemCount: _groupMessages.length,
              itemBuilder: (context, index) {
                String group = _groupMessages.elementAt(index);
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8),
                    title: Text(
                      group,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    trailing: Icon(Icons.arrow_forward),
                    onTap: () => _switchGroup(group),
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

   Future<void> _fetchGroupList() async {
     try {
       final response = await http.get(
         Uri.parse("http://192.168.3.4:8080/group/list"),
       );
       logger.d(response);

       if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
         logger.d(data);
         List<dynamic> groupList = data['data'];
         setState(() {
           _groupMessages = groupList.cast<String>();
         });
       }
     } catch (e) {
       print(e.toString());
     } finally {}
   }
}
