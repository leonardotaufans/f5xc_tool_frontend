class AuthResponse {
  int statusCode;
  String? error;
  AuthModel? auth;

  AuthResponse({required this.statusCode, this.error, this.auth});
}

class AuthModel {
  String? user;
  String? fullName;
  String? role;

  AuthModel({this.user, this.fullName, this.role});

  AuthModel.fromJson(Map<String, dynamic> json) {
    user = json['user'];
    fullName = json['full_name'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user'] = user;
    data['full_name'] = fullName;
    data['role'] = role;
    return data;
  }
}
