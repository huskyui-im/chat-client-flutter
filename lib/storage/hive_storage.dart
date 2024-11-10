import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
}

Future<void> saveCurrentUserInfo( String userName) async {
  var box = await Hive.openBox('currentUser');
  await box.put('userName', userName);
}

Future<String> getCurrentUser() async {
  var box = await Hive.openBox('currentUser');
  String userName = box.get('userName', defaultValue: '');
  return userName;
}



