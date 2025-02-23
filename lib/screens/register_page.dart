import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../constants/config_constants.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _imagePath = "";
  bool _isLoading = false;
  final logger = Logger();
  File? _image;

  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  final _focusPassword = FocusNode();





  @override
  void dispose() {
    _focusPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade800,
              Colors.indigo.shade900,
            ]
                : [
              Colors.purple.shade50,
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '创建账号',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 32),
                      _buildAvatarSection(),
                      SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: '用户名',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入用户名';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_focusPassword),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _focusPassword,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: '密码',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入密码';
                          }
                          if (value.length < 6) {
                            return '密码至少6位';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: theme.colorScheme.primary,
                          ),
                          onPressed: _isLoading ? null : _register,
                          child: Text(
                            '立即注册',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('已有账号？'),
                            SizedBox(width: 4),
                            Text(
                              '立即登录',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 48,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: _imagePath.isNotEmpty
                ? NetworkImage(_imagePath)
                : null,
            child: _imagePath.isEmpty
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt, size: 32, color: Colors.grey),
                SizedBox(height: 4),
                Text(
                  '添加头像',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            )
                : null,
          ),
        ),
        SizedBox(height: 8),
        if (_image != null)
          TextButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.refresh, size: 16),
            label: Text('更换头像'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }


  // 选择图片
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await uploadImage(pickedFile);
    }
  }

  Future<void> uploadImage(XFile image) async {
    String url = "$http_server/upload/image";
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
        setState(() {
          _imagePath = imgUrl;
        });
      } else {
        print("图片上传失败：${response.statusCode}");
      }
    } catch (e) {
      print("上传出错：$e");
    }
  }

  // 注册方法
  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    // 模拟发送请求，延迟2秒
    final response = await http.post(
      Uri.parse("$http_server/auth/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
        'avatar': _imagePath
      }),
    );
    logger.d(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      logger.d(data);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('注册成功！')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('注册失败！')));
    }

    // 这里可以添加实际的请求逻辑，比如通过HTTP包发送请求
    // 比如使用dio包发送请求

    setState(() {
      _isLoading = false;
    });

    // 清空输入框和图片
    _usernameController.clear();
    _passwordController.clear();
    // todo 跳转到登录页面

    // 显示成功提示
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('注册成功！')));
    // 在这里执行返回操作
    Navigator.pop(context, true);
  }
}
