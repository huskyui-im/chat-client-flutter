import 'package:chat_client/websocket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OpTypeConstants.dart';


class CreateGroupWidget extends StatefulWidget {
  @override
  _CreateGroupState createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroupWidget> {
  final TextEditingController _groupNameController = TextEditingController();
  late WebSocketManager webSocketManager;


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
              ElevatedButton(onPressed: _createGroup, child: Text('新建群组')),
            ],
          ),
        ),
      ),
    );
  }


  void _createGroup(){
    String groupName = _groupNameController.text;
    webSocketManager.sendMessage(OpTypeConstants.CREATE_GROUP, groupName, "");
  }
}