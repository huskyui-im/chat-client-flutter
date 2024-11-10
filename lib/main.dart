import 'package:chat_client/constants/config_constants.dart';
import 'package:chat_client/screens/create_group.dart';
import 'package:chat_client/screens/register_page.dart';
import 'package:chat_client/storage/hive_storage.dart';
import 'package:chat_client/websocket/websocket.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:logger/logger.dart';

import 'screens/chat_page.dart';

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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _token;
  final logger = Logger();

  // 登录请求

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      _showError("请输入用户名");
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse("http://$ip:8080/auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username,'password':password}),
      );
      logger.d(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['data']['token'];
        final username = data['data']['username'];
        saveCurrentUserInfo(username);
        setState(() {
          _token = token;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MultiGroupChatPage(token: _token!)),
        );
      } else {
        _showError("登录失败");
      }
    } catch (e) {
      _showError(e.toString());
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
                decoration: const InputDecoration(labelText: '用户名'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: '密码'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(onPressed: _login, child: const Text('登录')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _register, child: const Text("注册"))
            ],
          ),
        ),
      ),
    );
  }

  void _register() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RegisterPage()),
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
    WebSocketManager().connect('ws://$ip:8888/ws?token=${widget.token}');
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

  void _createGroup() async{
    // 导航到聊天页面
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateGroupWidget()),
    );
    if(shouldRefresh){
      _fetchGroupList();
    }
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
         Uri.parse("http://$ip:8080/group/list"),
       );
       logger.d(response);

       if (response.statusCode == 200) {
         final data = jsonDecode(const Utf8Decoder().convert(response.bodyBytes));
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
