import 'dart:convert';

import 'package:chat_client/model/group_info.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../constants/config_constants.dart';
import '../websocket/websocket.dart';
import 'chat_page.dart';
import 'create_group.dart';

import 'package:http/http.dart' as http;

class MultiGroupChatPage extends StatefulWidget {
  final String token;

  MultiGroupChatPage({required this.token});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<MultiGroupChatPage> {
  List<GroupInfo> _groupMessages = [];

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

  void _createGroup() async {
    // 导航到聊天页面
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateGroupWidget()),
    );
    if (shouldRefresh) {
      _fetchGroupList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("群组"), actions: <Widget>[
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
                String group = _groupMessages.elementAt(index).name;
                String avatar = _groupMessages.elementAt(index).avatar;
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(image_prefix+avatar),
                    ),
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
        final data =
            jsonDecode(const Utf8Decoder().convert(response.bodyBytes));
        logger.d(data);
        List<dynamic> groupList = data['data'];
        setState(() {
          print(groupList);
          _groupMessages = groupList.map((groupData)=>GroupInfo.fromJson(groupData)).toList();
          print(_groupMessages);
        });
      }
    } catch (e) {
      print(e.toString());
    } finally {}
  }
}
