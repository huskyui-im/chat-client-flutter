import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../constants/config_constants.dart';
import '../constants/op_type_constants.dart';
import '../websocket/websocket.dart';

class CreateGroupWidget extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroupWidget> {
  final TextEditingController _groupNameController = TextEditingController();
  late WebSocketManager webSocketManager;
  File? _image;
  String _imagePath = "";
  bool _isUploading = false;
  bool _isCreating = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    webSocketManager = WebSocketManager();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新建群组', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        iconTheme: IconThemeData(color: Colors.white),
      ),
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
                  _buildAvatarPicker(),
                  SizedBox(height: 30),
                  _buildGroupNameField(),
                  SizedBox(height: 40),
                  _buildCreateButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupNameField() {
    return TextField(
      controller: _groupNameController,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: '群组名称',
        labelStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(Icons.group, color: Colors.white70),
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
    );
  }

  Widget _buildAvatarPicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.blue.shade200,
            ),
            child: _isUploading
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : _image == null
                ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                : ClipOval(
              child: Image.network(
                _image!.path,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          '点击选择群头像',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isCreating ? null : _createGroup,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
        child: _isCreating
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : Text(
          '创建群组',
          style: TextStyle(
            fontSize: 18,
            color: Colors.blue.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _isUploading = true;
      });
      await uploadImage(pickedFile);
      setState(() => _isUploading = false);
    }
  }

  Future<void> uploadImage(XFile image) async {
    String url = "http://$ip:8080/upload/image";
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));
      var bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'upload.jpg',
      ));

      var response = await request.send();
      if (response.statusCode == 200) {
        final data = jsonDecode(await response.stream.bytesToString());
        setState(() => _imagePath = data['data']);
      } else {
        _showError("图片上传失败");
      }
    } catch (e) {
      _showError("上传出错：$e");
    }
  }

  void _createGroup() async {
    if (_groupNameController.text.isEmpty) {
      _showError("请输入群组名称");
      return;
    }

    setState(() => _isCreating = true);
    var ext = {
      "avatar": _imagePath,
    };



    try {
      // 这里替换为实际的创建群组逻辑
      webSocketManager.sendMessageWithExt(OpTypeConstants.CREATE_GROUP, _groupNameController.text, "",ext);
      Navigator.pop(context, true);
    } finally {
      setState(() => _isCreating = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('提示', style: TextStyle(color: Colors.red)),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('确定', style: TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}