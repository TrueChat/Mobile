class EditGroupResponse {
  const EditGroupResponse({this.id, this.name, this.description});

  factory EditGroupResponse.fromJson(Map<String, dynamic> json) {
    return EditGroupResponse(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  final int id;
  final String name;
  final String description;
}
