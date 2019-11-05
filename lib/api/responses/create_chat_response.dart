class CreateChatResponse {
  const CreateChatResponse({this.id, this.name, this.description});

  factory CreateChatResponse.fromJson(Map<String, dynamic> json) {
    return CreateChatResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  final int id;
  final String name;
  final String description;
}
