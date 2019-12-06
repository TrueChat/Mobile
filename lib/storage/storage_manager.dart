import 'package:flutter/material.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _secureStorage = FlutterSecureStorage();

Future<void> saveAccessToken({@required String accessToken}) async {
  await _secureStorage.write(key: accessTokenKey, value: accessToken);
}

Future<void> saveUser({@required User user}) async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString(nameKey, user.firstName);
  pref.setString(surnameKey, user.lastName);
  pref.setString(usernameKey, user.username);
  pref.setString(aboutKey, user.about);
  pref.setInt(idKey, user.id);
  pref.setString(emailKey, user.email);
  pref.setString(dateJoinedKey, user.dateJoined);
  pref.setString(lastLoginKey, user.lastLogin);
  pref.setString(imageUrlKey, user.images[0].imageURL);
}

Future<User> getUser() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  return User.fromPref(pref: pref);
}

Future<String> getAccessToken() async {
  return await _secureStorage.read(key: accessTokenKey);
}

Future<bool> isLoggedIn() async {
  final String accessToken = await _secureStorage.read(key: accessTokenKey);
  return accessToken != null;
}

Future<void> deleteToken() async {
  await _secureStorage.delete(key: accessTokenKey);
}

Future<void> clear() async {
  final pref = await SharedPreferences.getInstance();
  await pref.clear();
  await _secureStorage.deleteAll();
}
