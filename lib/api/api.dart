import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const baseUrl = "";

class Api{
  //Helpers
  static String callUrl(String endpoint,[Map<String,String> query]){
    String res = baseUrl + endpoint;
    if(query != null){
      res += "?";
      query.forEach((key,value){
        res += "$key=$value&";
      });
    }
    return res.substring(0,res.length-1);
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

  static bool _isTokenExpired(String token){
    Map tokenDecode = _parseJwt(token);

    int exp = tokenDecode["exp"];
    int now = DateTime.now().millisecondsSinceEpoch;

    if (now <= exp * 1000) {
      return false;
    }
    return true;
  }
}