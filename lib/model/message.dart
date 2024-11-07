class Message {
  final int opType;
  final String group;
  final String message;
  final String sendUser;


  Message({required this.opType, required this.group, required this.message,required this.sendUser});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      opType: json['opType'],
      group: json['group'],
      message: json['message'],
      sendUser: json['sendUser'],
    );
  }
}