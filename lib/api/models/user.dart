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