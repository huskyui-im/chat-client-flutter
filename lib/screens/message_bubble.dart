import 'package:chat_client/constants/op_type_constants.dart';
import 'package:chat_client/model/message.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final String currentUser;

  const MessageBubble({
    required this.message,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: message.sendUser == currentUser
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(mainAxisAlignment: message.sendUser == currentUser ?MainAxisAlignment.end : MainAxisAlignment.start, children: [
              Text(message.sendUser),
              SizedBox(width: 16.0),
              Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: message.sendUser == currentUser ? Colors.blue[400] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: message.sendUser == currentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (message.opType == OpTypeConstants.SEND_MSG)
                        Text(
                          message.message,
                          style: TextStyle(color: Colors.white),
                        ),
                      if (message.opType == OpTypeConstants.SEND_IMAGE)
                        Image.network(
                          message.message,
                          width: 200,
                          height: 150,
                        ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ))
            ])));
  }
}
