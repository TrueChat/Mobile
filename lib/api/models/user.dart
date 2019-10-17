import 'package:shared_preferences/shared_preferences.dart';
import 'package:true_chat/helpers/constants.dart';

class User{
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String about;
  final String dateJoined;
  final String lastLogin;

  User({this.id, this.username, this.email, this.firstName, this.lastName,
      this.about, this.dateJoined, this.lastLogin});

  factory User.fromPref({SharedPreferences pref}){
    return User(
      id: pref.getInt(idKey),
      username: pref.getString(usernameKey),
      email: pref.getString(emailKey),
      firstName: pref.getString(nameKey),
      lastName: pref.getString(surnameKey),
      about: pref.getString(aboutKey),
      dateJoined: pref.getString(dateJoinedKey),
      lastLogin: pref.getString(lastLoginKey)
    );
  }

  factory User.fromJson(Map<String,dynamic> json){
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      about: json['about'],
      dateJoined: json['date_joined'],
      lastLogin: json['last_login'],
    );
  }
}