import 'package:flutter/material.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefManager{

  static Future<void> saveUser({@required String accessToken,
    @required String refreshToken}) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(accessTokenKey, accessToken);
    pref.setString(refreshTokenKey, refreshToken);
  }

  static Future<String> getAccessToken() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(accessTokenKey);
  }

  static Future<void> setAccessToken(String accessToken) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(accessTokenKey, accessToken);
  }

  static Future<String> getRefreshToken() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString(refreshTokenKey);
  }

  static Future<bool> isFirstLaunch() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(!pref.containsKey(isFirstLaunchKey)){
      pref.setBool(isFirstLaunchKey, false);
      return true;
    }
    return false;
  }

  static Future<bool> isLoggedIn() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.containsKey(accessTokenKey);
  }

  static Future<void> deleteTokens() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove(accessTokenKey);
    pref.remove(refreshTokenKey);
  }
}