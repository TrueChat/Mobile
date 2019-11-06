import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:true_chat/api/models/chat.dart';
import 'package:true_chat/api/responses/chats_response.dart';
import 'package:true_chat/api/responses/create_chat_response.dart';
import 'package:true_chat/api/responses/edit_group_response.dart';
import 'package:true_chat/api/responses/edit_user_response.dart';
import 'package:true_chat/api/responses/login_response.dart';
import 'package:true_chat/api/responses/response.dart';
import 'package:true_chat/api/responses/user_response.dart';
import 'package:true_chat/helpers/constants.dart';
import 'package:true_chat/storage/storage_manager.dart' as storage_manager;

import 'models/user.dart';

class ApiException implements Exception {
  const ApiException([this.message]);

  final String message;
}

const baseUrl = 'https://true-chat.herokuapp.com/';
const _registrationEndpoint = 'rest-auth/registration/';
const _loginEndpoint = 'rest-auth/login/';
const _profileEndpoint = 'profile';
const _logoutEndpoint = 'rest-auth/logout/';
const _chatsEndpoint = 'chats/';

String _chatEndpoint(int id) => 'chats/$id/';

String _profilesEndpoint(String searchQuery) => 'profiles/$searchQuery';

String _addUserToChatEndpoint(int chatId, String username) =>
    'chats/$chatId/add_member/$username/';

String _getProfileEndpoint(String username) => 'profile/$username';

String _banMemberEndpoint(int chatId, String username) =>
    'chats/$chatId/ban_member/$username/';

String _deleteMemberEndpoint(int chatId, String username) =>
    'chats/$chatId/delete_member/$username/';

Map<String, String> _postHeaders = {
  'accept': 'application/json',
  'Content-Type': 'application/json; charset=utf-8',
};

Map<String, String> _authHeader(String accessToken) =>
    {HttpHeaders.authorizationHeader: 'Token $accessToken'};

//Calls
Future<Response> registration({
  String username,
  String email,
  String password,
}) async {
  final data = <String, String>{
    'username': username,
    'email': email,
    'password1': password,
    'password2': password,
  };

  final body = json.encode(data);
  final response = await http.post(callUrl(_registrationEndpoint),
      headers: _postHeaders, body: body);

  if (response.statusCode >= 500) {
    return Response(true, smthWentWrong);
  }

  final Map<String, dynamic> res = json.decode(response.body);
  if (response.statusCode >= 200 && response.statusCode < 300) {
    return Response(false, 'Register Successful');
  }
  final message = '${res.values.toList()[0][0].toString()}';
  return Response(true, message);
}

Future<Response> login(
    {String username, String email, @required String password}) async {
  final data = <String, String>{
    if (email != null) 'email': email,
    if (username != null) 'username': username,
    'password': password
  };
  final url = callUrl(_loginEndpoint);
  final body = json.encode(data);
  final response = await http.post(url, headers: _postHeaders, body: body);

  if (response.statusCode >= 500) {
    return Response(true, smthWentWrong);
  }

  final Map<String, dynamic> res = json.decode(response.body);
  if (response.statusCode >= 200 && response.statusCode < 300) {
    await storage_manager.saveAccessToken(accessToken: res['key']);
    return LoginResponse(false, 'Login Successful', res['key']);
  }
  final message = '${res.values.toList()[0][0].toString()}';
  return Response(true, message);
}

Future<Response> getCurrentUser() async {
  final accessToken = await storage_manager.getAccessToken();

  final response = await http.get(callUrl(_profileEndpoint),
      headers: _authHeader(accessToken));
  if (response.statusCode >= 500) {
    return Response(true, smthWentWrong);
  }
  final Map<String, dynamic> res = json.decode(utf8Decode(response));
  if (response.statusCode >= 200 && response.statusCode < 300) {
    final user = User.fromJson(res);
    await storage_manager.saveUser(user: user);
    return UserResponse(false, 'User fetched successfuly', user);
  }
  final message = '${res.values.toList()[0][0].toString()};';
  return Response(true, message);
}

Future<Chat> getChat({@required int id}) async {
  if (await checkConnection()) {
    final accessToken = await storage_manager.getAccessToken();

    final response = await http.get(
      callUrl(_chatEndpoint(id)),
      headers: _authHeader(accessToken),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> chatJson = json.decode(utf8Decode(response));
      return Chat.fromJson(chatJson);
    }
    throw ApiException(smthWentWrong);
  }
  throw ApiException(noConnectionMessage);
}

Future<EditGroupResponse> editChat(
    {@required int id, String name, String description}) async {
  if (await checkConnection()) {
    final accessToken = await storage_manager.getAccessToken();

    final data = <String, String>{
      'name': name,
      'description': description,
    };

    final body = json.encode(data);

    final Map<String, String> _header = _postHeaders;
    _header.addAll(_authHeader(accessToken));

    final response = await http.put(
      callUrl(_chatEndpoint(id)),
      headers: _header,
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> chatJson = json.decode(utf8Decode(response));
      return EditGroupResponse.fromJson(chatJson);
    }
    throw ApiException(smthWentWrong);
  }
  throw ApiException(noConnectionMessage);
}

Future<Chat> banMember({int chatId, String username}) async {
  if (await checkConnection()) {
    final accessToken = await storage_manager.getAccessToken();

    final response = await http.put(
      callUrl(_banMemberEndpoint(chatId, username)),
      headers: _authHeader(accessToken),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> chatJson = json.decode(utf8Decode(response));
      return Chat.fromJson(chatJson);
    }
    throw ApiException(smthWentWrong);
  }
  throw ApiException(noConnectionMessage);
}

Future<Chat> kickMember({int chatId, String username}) async{
  if (await checkConnection()) {
    final accessToken = await storage_manager.getAccessToken();

    final response = await http.delete(
      callUrl(_deleteMemberEndpoint(chatId, username)),
      headers: _authHeader(accessToken),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> chatJson = json.decode(utf8Decode(response));
      return Chat.fromJson(chatJson);
    }
    throw ApiException(smthWentWrong);
  }
  throw ApiException(noConnectionMessage);
}

Future<List<User>> searchUser({@required String query}) async {
  if (await checkConnection()) {
    final accessToken = await storage_manager.getAccessToken();

    final response = await http.get(
      callUrl(_profilesEndpoint(query)),
      headers: _authHeader(accessToken),
    );
    if (response.statusCode == 200) {
      final List<dynamic> userJson = json.decode(utf8Decode(response));
      final List<User> users =
          userJson.map((dynamic el) => User.fromJson(el)).toList();
      return users;
    }
    throw ApiException(smthWentWrong);
  }
  throw ApiException(noConnectionMessage);
}

Future<User> getProfile({String username}) async {
  if (await checkConnection()) {
    final accessToken = await storage_manager.getAccessToken();

    final response = await http.get(
      callUrl(_getProfileEndpoint(username)),
      headers: _authHeader(accessToken),
    );
    if (response.statusCode == 200) {
      final dynamic userJson = json.decode(utf8Decode(response));
      return User.fromJson(userJson);
    }
    throw ApiException(smthWentWrong);
  }
  throw ApiException(noConnectionMessage);
}

Future<ChatsResponse> fetchChats(int page) async {
  if (await checkConnection()) {
    final accessToken = await storage_manager.getAccessToken();

    final response = await http.get(
      callUrl(_chatsEndpoint, query: <String, String>{
        'page': page.toString(),
      }),
      headers: _authHeader(accessToken),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> chatsJson = json.decode(utf8Decode(response));
      return ChatsResponse.fromJson(chatsJson);
    }
    throw ApiException(smthWentWrong);
  }
  throw ApiException(noConnectionMessage);
}

Future<CreateChatResponse> createChat(
    {@required String name, @required String description}) async {
  if (await checkConnection()) {
    final accessToken = await storage_manager.getAccessToken();

    final data = <String, String>{
      'name': name,
      'description': description,
    };
    final url = callUrl(_chatsEndpoint);
    final body = json.encode(data);
    final Map<String, String> _header = _postHeaders;
    _header.addAll(_authHeader(accessToken));

    final response = await http.post(url, headers: _header, body: body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> chatsJson = json.decode(utf8Decode(response));
      return CreateChatResponse.fromJson(chatsJson);
    }
    throw ApiException(smthWentWrong);
  }
  throw ApiException(noConnectionMessage);
}

Future<Chat> addUserToChat(
    {@required int chatId, @required String username}) async {
  if (await checkConnection()) {
    final accessToken = await storage_manager.getAccessToken();

    final url = callUrl(_addUserToChatEndpoint(chatId, username));
    final Map<String, String> _header = _postHeaders;
    _header.addAll(_authHeader(accessToken));

    final response = await http.post(url, headers: _header);

    if (response.statusCode == 200) {
      final Map<String, dynamic> chatJson = json.decode(utf8Decode(response));
      return Chat.fromJson(chatJson);
    }
    throw ApiException(smthWentWrong);
  }
  throw ApiException(noConnectionMessage);
}

Future<Response> logout() async {
  final accessToken = await storage_manager.getAccessToken();

  try {
    final response = await http.post(callUrl(_logoutEndpoint),
        headers: _authHeader(accessToken));
    if (response.statusCode >= 500) {
      return Response(true, smthWentWrong);
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      await storage_manager.clear();
      return Response(false, 'Logout successfully');
    }
    return Response(true, smthWentWrong);
  } catch (_) {
    return Response(true, noConnectionMessage);
  }
}

Future<Response> changeUserData(
    {String name,
    String surname,
    String bio,
    @required String username}) async {
  final accessToken = await storage_manager.getAccessToken();

  final data = <String, String>{
    if (name != null) 'first_name': name,
    if (bio != null) 'about': bio,
    if (surname != null) 'last_name': surname,
    'username': username
  };

  String body;

  if (data.isNotEmpty) {
    body = json.encode(data);
  }

  final headers = <String, String>{};
  headers.addAll(_authHeader(accessToken));
  headers.addAll(_postHeaders);

  final response = await http.put(
    '${callUrl(_profileEndpoint)}/',
    headers: headers,
    body: body,
  );

  if (response.statusCode >= 500) {
    return Response(true, smthWentWrong);
  }
  final Map<String, dynamic> res = json.decode(utf8Decode(response));
  if (response.statusCode >= 200 && response.statusCode < 300) {
    await getCurrentUser();
    return EditUserResponse.fromJson(res);
  }
  final message = '${res.values.toList()[0][0].toString()}';
  return Response(true, message);
}

//Helpers
String callUrl(String endpoint, {Map<String, String> query}) {
  String res = baseUrl + endpoint;
  if (query != null) {
    res += '?';
    query.forEach((key, value) {
      res += '$key=$value&';
    });
  }
  if (query != null) {
    res.substring(0, res.length - 1);
  }
  return res;
}

String utf8Decode(http.Response response) => utf8.decode(response.bodyBytes);

//Map<String, dynamic> _parseJwt(String token) {
//  final parts = token.split('.');
//  if (parts.length != 3) {
//    throw Exception('invalid token');
//  }
//
//  final payload = _decodeBase64(parts[1]);
//  final Map<String, dynamic> payloadMap = json.decode(payload);
//  if (payloadMap is! Map<String, dynamic>) {
//    throw Exception('invalid payload');
//  }
//
//  return payloadMap;
//}
//
//String _decodeBase64(String str) {
//  String output = str.replaceAll('-', '+').replaceAll('_', '/');
//
//  switch (output.length % 4) {
//    case 0:
//      break;
//    case 2:
//      output += '==';
//      break;
//    case 3:
//      output += '=';
//      break;
//    default:
//      throw Exception('Illegal base64url string!"');
//  }
//  return utf8.decode(base64Url.decode(output));
//}
//
//bool _isTokenExpired(String token) {
//  final tokenDecode = _parseJwt(token);
//
//  final int exp = tokenDecode['exp'];
//  final int now = DateTime.now().millisecondsSinceEpoch;
//
//  if (now <= exp * 1000) {
//    return false;
//  }
//  return true;
//}
