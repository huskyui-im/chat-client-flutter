import 'dart:convert';
import 'dart:io';

import 'package:chat_client/websocket/websocket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/config_constants.dart';
import '../constants/op_type_constants.dart';

import 'package:http/http.dart' as http;


class CreateGroupWidget extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroupWidget> {
  final TextEditingController _groupNameController = TextEditingController();
  late WebSocketManager webSocketManager;
  File? _image;
  String _imagePath = "";

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
        title: Text('新建群组'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(labelText: '群组名称'),
              ),
              SizedBox(height: 20),
              _image == null
                  ? Text('群头像未选择')
                  : Image.network(
                _image!.path,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('选择群头像'),
              ),
              ElevatedButton(onPressed: _createGroup, child: Text('新建群组')),
            ],
          ),
        ),
      ),
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


  void _createGroup(){
    String groupName = _groupNameController.text;
    if(groupName.isEmpty){
      _showError("群名为空");
      return;
    }
    var ext = {
      "avatar": _imagePath,
    };


    webSocketManager.sendMessageWithExt(OpTypeConstants.CREATE_GROUP, groupName, "",ext);
    // 在这里执行返回操作
    Navigator.pop(context,true);
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
}
