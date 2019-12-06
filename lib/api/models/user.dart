import 'package:shared_preferences/shared_preferences.dart';
import 'package:true_chat/helpers/constants.dart';

import 'message.dart';

class User {

  User({this.id, this.username, this.email, this.firstName, this.lastName,
    this.about, this.dateJoined, this.lastLogin,this.images});

  factory User.fromPref({SharedPreferences pref}){
    return User(
        id: pref.getInt(idKey),
        username: pref.getString(usernameKey),
        email: pref.getString(emailKey),
        firstName: pref.getString(nameKey),
        lastName: pref.getString(surnameKey),
        about: pref.getString(aboutKey),
        dateJoined: pref.getString(dateJoinedKey),
        lastLogin: pref.getString(lastLoginKey),
        images: <ImageDTO>[ImageDTO(imageURL: pref.getString(imageUrlKey))]
    );
  }

  factory User.fromJson(Map<String, dynamic> json){
    final List<dynamic> imagesList = json['images'];
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      about: json['about'],
      dateJoined: json['date_joined'],
      lastLogin: json['last_login'],
      images:imagesList.map((dynamic el) => ImageDTO.fromJson(el)).toList()
    );
  }

  User copyWith(
      {int id, String username, String email, String firstName, String lastName,
        String about, String dateJoined, String lastLogin,List<ImageDTO> images}){
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      about: about ?? this.about,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
      images: images ?? this.images
    );
  }

  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String about;
  final String dateJoined;
  final String lastLogin;
  final List<ImageDTO> images;
}