class UserStatistics {
  const UserStatistics(
      {this.chatsNum,
      this.dialogsNum,
      this.groupsNum,
      this.daysWith,
      this.messagesNum,
      this.wordsNum,
      this.charsNum,
      this.activePeriod,
      this.actMessagesNum,
      this.actWordsNum,
      this.actCharsNum});

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      chatsNum: json['chats_num'],
      dialogsNum: json['dialogs_num'],
      groupsNum: json['groups_num'],
      daysWith: json['days_with'],
      messagesNum: json['mess_num'],
      wordsNum: json['words_num'],
      charsNum: json['chars_num'],
      activePeriod: json['active_period'],
      actMessagesNum: json['act_mess_num'],
      actWordsNum: json['act_words_num'],
      actCharsNum: json['act_chars_num'],
    );
  }

  final int chatsNum;
  final int dialogsNum;
  final int groupsNum;
  final int daysWith;
  final int messagesNum;
  final int wordsNum;
  final int charsNum;
  final String activePeriod;
  final int actMessagesNum;
  final int actWordsNum;
  final int actCharsNum;
}
