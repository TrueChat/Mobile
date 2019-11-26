class ChatStatistics{
  const ChatStatistics({this.messagesNum, this.usersNum, this.daysExists,
    this.meanMessChars, this.meanMessWords, this.activeUsersNum,
    this.afkUsersNum, this.members});

  factory ChatStatistics.fromJson(Map<String,dynamic> json){
    final List<dynamic> membersList = json['members'];
    return ChatStatistics(
      messagesNum: json['mess_num'],
      usersNum: json['users_num'],
      daysExists: json['days_exist'],
      meanMessChars: json['mean_mess_chars'],
      meanMessWords: json['mean_mess_words'],
      activeUsersNum: json['act_users_num'],
      afkUsersNum: json['afk_users_num'],
      members: membersList.map((dynamic el) => ChatUserStatistics.fromJson(el)).toList(),
    );
  }

  final int messagesNum;
  final int usersNum;
  final int daysExists;
  final double meanMessChars;
  final double meanMessWords;
  final int activeUsersNum;
  final int afkUsersNum;
  final List<ChatUserStatistics> members;
}

class ChatUserStatistics{
  const ChatUserStatistics({this.username, this.meanChar, this.meanWord,
    this.messagesNum, this.wordsNum, this.charsNum, this.messagesPercent,
    this.daysIn});

  factory ChatUserStatistics.fromJson(Map<String,dynamic> json){
    return ChatUserStatistics(
      username: json['username'],
      meanChar: json['mean_char'],
      meanWord: json['mean_word'],
      messagesNum: json['num_mess'],
      wordsNum: json['num_words'],
      charsNum: json['num_chars'],
      messagesPercent: json['percent'],
      daysIn: json['days_in'],
    );
  }

  final String username;
  final double meanChar;
  final double meanWord;
  final int messagesNum;
  final int wordsNum;
  final int charsNum;
  final double messagesPercent;
  final int daysIn;
}