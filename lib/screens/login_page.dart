import 'dart:convert';

import 'package:chat_client/screens/register_page.dart';
import 'package:flutter/material.dart';
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade400,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '欢迎回来',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildInputField(
                    controller: _usernameController,
                    label: '用户名',
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    controller: _passwordController,
                    label: '密码',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  SizedBox(height: 30),
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : _buildLoginButton(),
                  SizedBox(height: 20),
                  _buildRegisterRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      onSubmitted: (_) => _login(),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
        child: Text(
          '登 录',
          style: TextStyle(
            fontSize: 18,
            color: Colors.blue.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('新用户？', style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: _register,
          child: Text(
            '立即注册',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }
}
