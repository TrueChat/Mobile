import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:true_chat/api/responses/login_response.dart';
import 'package:true_chat/api/responses/response.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/storage/storage_manager.dart';

class Api {
  static const String _registrationEndpoint = "rest-auth/registration/";
  static const String _loginEndpoint = 'rest-auth/login/';

  static Map<String, String> _postHeaders = {
    "accept": "application/json",
    "content-type": "application/json"
  };

  static Map<String, String> _authHeader(String refreshToken) =>
      {HttpHeaders.authorizationHeader: "Basic $refreshToken"};

  //Calls

  static Future<Response> registration({
    String username,
    String email,
    String password,
  }) async {
    Map data = {
      "username": username,
      "email": email,
      "password1": password,
      "password2": password,
    };

    String body = json.encode(data);
    final response = await http.post(callUrl(_registrationEndpoint),
        body: body, headers: _postHeaders);
    var res = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      await StorageManager.saveUser(accessToken: res['key']);
      return LoginResponse(false, "Register Successful", res['key']);
    }
    String message = '';
    for (MapEntry<String, List<String>> en in res) {
      message += '${en.key}: ${en.value[0]};';
    }
    return Response(true, message);
  }

  static Future<Response> login(
      {String username, String email, @required String password}) async {
    Map data = {
      if (username != null) 'username': username,
      if (email != null) 'email': email,
      'password': password
    };

    String body = json.encode(data);
    final response = await http.post(callUrl(_loginEndpoint),
        body: body, headers: _postHeaders);
    var res = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      await StorageManager.saveUser(accessToken: res['key']);
      return LoginResponse(false, "Login Successful", res['key']);
    }
    String message = '';
    for (MapEntry<String, List<String>> en in res) {
      message += '${en.key}: ${en.value[0]};';
    }
    return Response(true, message);
  }

  //Helpers
  static String callUrl(String endpoint, [Map<String, String> query]) {
    String res = baseUrl + endpoint;
    if (query != null) {
      res += "?";
      query.forEach((key, value) {
        res += "$key=$value&";
      });
    }
    return res.substring(0, res.length - 1);
  }

  static Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  static String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }
    return utf8.decode(base64Url.decode(output));
  }

  static bool _isTokenExpired(String token) {
    Map tokenDecode = _parseJwt(token);

    int exp = tokenDecode["exp"];
    int now = DateTime.now().millisecondsSinceEpoch;

    if (now <= exp * 1000) {
      return false;
    }
    return true;
  }
}
