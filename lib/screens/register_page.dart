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
      Uri.parse("http://$ip:8080/auth/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': _usernameController.text, 'password': _passwordController.text, 'avatar': _imagePath}),
    );
    logger.d(response);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      logger.d(data);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('注册成功！')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('注册失败！')));
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('注册成功！')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: '用户名'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: '密码'),
                obscureText: true,
              ),
              SizedBox(height: 16),
              _image == null
                  ? Text('头像未选择')
                  : Image.network(
                _image!.path,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('选择头像'),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _register,
                child: Text('注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
