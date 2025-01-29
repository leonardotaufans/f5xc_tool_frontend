class LoginResult {
  int responseCode;
  Map<String, dynamic>? description;
  LoginModel? loginData;

  LoginResult({required this.responseCode, this.description, this.loginData});
}

class LoginModel {
  String? accessToken;
  String? tokenType;
  String? role;
  User? user;

  LoginModel({this.accessToken, this.tokenType, this.role, this.user});

  LoginModel.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    tokenType = json['token_type'];
    role = json['role'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['access_token'] = accessToken;
    data['token_type'] = tokenType;
    data['role'] = role;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  String? username;
  String? fullName;
  String? email;

  User({this.username, this.fullName, this.email});

  User.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    fullName = json['full_name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['full_name'] = fullName;
    data['email'] = email;
    return data;
  }
}
