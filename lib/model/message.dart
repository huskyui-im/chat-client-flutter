class Message {
  final int opType;
  final String group;
  final String message;

  Message({required this.opType, required this.group, required this.message});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      opType: json['opType'],
      group: json['group'],
      message: json['message'],
    );
  }
}