import 'package:chat_client/constants/op_type_constants.dart';
import 'package:chat_client/model/message.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({
    required this.message,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(message.sendUser),
          SizedBox(width: 16.0),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.blue[300],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(message.opType == OpTypeConstants.SEND_MSG)
                  Text(message.message, style: TextStyle(color: Colors.white),),
                if(message.opType == OpTypeConstants.SEND_IMAGE)
                  Image.network(message.message, width: 200, height: 150,),
                SizedBox(height: 5,)
              ],
            )
          )
        ])
    );
  }


}