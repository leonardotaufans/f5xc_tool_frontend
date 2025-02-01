class UserResponse {
  final int statusCode;
  final String? message;
  final UserModel? model;

  UserResponse({required this.statusCode, this.message, this.model});
}

class ListUserResponse {
  final int statusCode;
  final String? message;
  final List<UserModel>? userList;

  ListUserResponse({required this.statusCode, this.message, this.userList});
}

class UserModel {
  String? username;
  String? fullName;
  String? organization;
  bool? isActive;
  String? email;
  int? registrationDate;
  String? registeredBy;
  String? role;

  UserModel(
      {this.username,
      this.fullName,
      this.organization,
      this.isActive,
      this.email,
      this.registrationDate,
      this.registeredBy,
      this.role});

  UserModel.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    fullName = json['full_name'];
    organization = json['organization'];
    isActive = json['is_active'];
    email = json['email'];
    registrationDate = json['registration_date'];
    registeredBy = json['registered_by'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['full_name'] = fullName;
    data['organization'] = organization;
    data['is_active'] = isActive;
    data['email'] = email;
    data['registration_date'] = registrationDate;
    data['registered_by'] = registeredBy;
    data['role'] = role;
    return data;
  }
}
