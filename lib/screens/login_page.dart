import 'dart:convert';

import 'package:chat_client/screens/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

import '../constants/config_constants.dart';
import '../storage/hive_storage.dart';
import 'multiple_group.dart';

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
  final FocusNode _focusNode = FocusNode();

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
        body: jsonEncode({'username': username, 'password': password}),
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
                onSubmitted: (_){
                  _login();
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(onPressed: _login, child: const Text('登录')),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _register, child: const Text("注册")),
            ],
          ),
        ),
      ),
    );
  }

  void _register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }
}
