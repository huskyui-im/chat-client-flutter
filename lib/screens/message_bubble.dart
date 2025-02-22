import 'dart:convert';

import 'package:chat_client/constants/op_type_constants.dart';
import 'package:chat_client/model/message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/config_constants.dart';
import 'package:http/http.dart' as http;

import '../storage/hive_storage.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final String currentUser;

  const MessageBubble({
    required this.message,
    required this.currentUser,
  });

  // 假设这个函数模拟根据userId从API获取头像
  Future<String> getUserAvatar(String userId) async {
    String cacheAvatar = await getAvatarCache(userId);
    if(cacheAvatar.isNotEmpty){
      return cacheAvatar;
    }

    String url = "$http_server/user/info?userId=$userId";
    try {
      var request = http.MultipartRequest("GET", Uri.parse(url));
      var response = await request.send();
      if (response.statusCode == 200) {
        final data = jsonDecode(await response.stream.bytesToString());
        final imgUrl = data['data']['avatar'];
        // 缓存头像
        final imageFullPath = image_prefix+imgUrl;
        await putAvatarCache(userId, imageFullPath);
        return imageFullPath;
      }
    } catch (e) {
      if (kDebugMode) {
        print("获取头像错误：$e");
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: message.sendUser == currentUser
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
                mainAxisAlignment: message.sendUser == currentUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  // 获取头像
                  FutureBuilder<String>(
                    future: getUserAvatar(message.sendUser), // 根据用户id获取头像
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // 如果加载中，显示加载进度条
                      } else if (snapshot.hasError) {
                        return const Icon(Icons.error); // 如果出错，显示错误图标
                      } else if (snapshot.hasData) {
                        // 如果获取成功，显示头像
                        return CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(snapshot.data!),
                        );
                      } else {
                        return const Icon(Icons.account_circle); // 如果没有头像，显示默认头像
                      }
                    },
                  ),
                  // Text(message.sendUser),
                  const SizedBox(width: 16.0),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 10),
                      decoration: BoxDecoration(
                        color: message.sendUser == currentUser
                            ? Colors.blue[400]
                            : Colors.grey[300],
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
                              style: const TextStyle(color: Colors.white),
                            ),
                          if (message.opType == OpTypeConstants.SEND_IMAGE)
                            Image.network(
                              message.message,
                              width: 200,
                              height: 150,
                            ),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ))
                ])));
  }
}
