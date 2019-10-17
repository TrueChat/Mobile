import 'package:flutter/material.dart';
import 'package:true_chat/api/models/user.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageManager {
  static final _secureStorage = FlutterSecureStorage();

  static Future<void> saveAccessToken({@required String accessToken}) async {
    await _secureStorage.write(key: accessTokenKey, value: accessToken);
  }

  static Future<void> saveUser({@required User user}) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(nameKey, user.firstName);
    pref.setString(surnameKey, user.lastName);
    pref.setString(usernameKey, user.username);
    pref.setString(aboutKey, user.about);
    pref.setInt(idKey, user.id);
    pref.setString(emailKey, user.email);
    pref.setString(dateJoinedKey, user.dateJoined);
    pref.setString(lastLoginKey, user.lastLogin);
  }

  static Future<User> getUser() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return User.fromPref(pref: pref);
  }

  static Future<String> getAccessToken() async {
    return await _secureStorage.read(key: accessTokenKey);
  }

  static Future<bool> isFirstLaunch() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey(isFirstLaunchKey)) {
      await pref.setBool(isFirstLaunchKey, false);
      return true;
    }
    return false;
  }

  static Future<bool> isLoggedIn() async {
    String accessToken = await _secureStorage.read(key: accessTokenKey);
    return accessToken != null;
  }

  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: accessTokenKey);
  }

  static Future<void> clear() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();
    await _secureStorage.deleteAll();
  }
}
