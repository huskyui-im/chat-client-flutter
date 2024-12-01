class GroupInfo{
  final int id;
  final String name;
  final String avatar;


// Constructor to initialize the fields
  GroupInfo({required this.id, required this.name, required this.avatar});

  // Factory constructor to create a GroupInfo object from JSON data
  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      id: json['id'] ?? 0,  // Default to empty string if not found
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',  // Default to empty string if not found
    );
  }

}