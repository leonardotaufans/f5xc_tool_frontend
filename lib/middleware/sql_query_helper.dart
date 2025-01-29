import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/model/auth_model.dart';
import 'package:f5xc_tool/model/login_model.dart';
import 'package:f5xc_tool/model/revision_model.dart';
import 'package:f5xc_tool/model/version_model.dart';

class SqlQueryHelper {
  Dio dio = Dio(BaseOptions(baseUrl: Configuration().middlewareHost));

  // Login
  Future<LoginResult> login(String username, String rawPassword) async {
    FormData requestBody =
        FormData.fromMap({"username": username, "password": rawPassword});
    Map<String, String> requestHeader = {
      "Accept": "*/*",
      "X-Requested-With": "XMLHttpRequest"
    };
    BaseOptions options = BaseOptions(
        baseUrl: Configuration().middlewareHost,
        contentType: 'application/json',
        method: 'POST');
    Dio dio = Dio(options);
    var req = await dio.post('/mgmt/login', data: requestBody);
    LoginResult exception = LoginResult(
        responseCode: 401,
        description: {"error": "Username/password is incorrect"});
    if (req.statusCode! > 200) {
      return exception;
    } else {
      return LoginResult(
          responseCode: 200, loginData: LoginModel.fromJson(req.data));
    }
  }

  Future<AuthResponse> verifyAuth(String bearer) async {
    AuthResponse exception =
        AuthResponse(statusCode: 401, error: "Bearer invalid or empty.");
    try {
      if (bearer.isEmpty) {
        return exception;
      }
      Map<String, String> header = {
        HttpHeaders.authorizationHeader: "Bearer $bearer"
      };
      var request =
          await dio.post('/test/token', options: Options(headers: header));
      if (request.statusCode! > 200) {
        return AuthResponse(
            statusCode: request.statusCode ?? 401,
            error: request.statusMessage);
      } else {
        Map<String, dynamic> response = request.data;
        return AuthResponse(
            statusCode: 200, auth: AuthModel.fromJson(response));
      }
    } on DioException {
      return exception;
    }
  }

  Future<ListVersionModel> getApps(PolicyType type, String bearer) async {
    ListVersionModel exception = ListVersionModel(
        responseCode: 401, error: "You are not authenticated!");
    if (bearer.isEmpty) {
      return exception;
    }
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $bearer'
    };
    Map<String, dynamic> queryParameters = {};
    if (type == PolicyType.staging) {
      queryParameters.addAll({"environment": "staging"});
    }
    if (type == PolicyType.production) {
      queryParameters.addAll({"environment": "production"});
    }
    Options options = Options(
        method: 'GET',
        contentType: 'application/json',
        headers: headers,
        responseType: ResponseType.json);
    var request = await dio.get('/xc/app',
        queryParameters: queryParameters, options: options);
    // print(request.data.toString());
    if (request.statusCode! > 200) {
      return ListVersionModel(
          responseCode: request.statusCode ?? 400,
          error: request.statusMessage);
    } else {
      List<VersionModel> data = [];
      for (var each in request.data) {
        data.add(VersionModel.fromJson(each));
      }
      return ListVersionModel(responseCode: 200, versionData: data);
    }
  }

  Future<ListRevisionModel> getAllRevisions(
      String bearer, String appName, PolicyType type) async {
    ListRevisionModel exceptions =
        ListRevisionModel(responseCode: 401, errorMessage: "Bearer is missing");
    if (bearer.isEmpty) {
      return exceptions;
    }
    if (appName.isEmpty) {
      return ListRevisionModel(
          responseCode: 400, errorMessage: "App name is missing");
    }
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $bearer'
    };
    Map<String, dynamic> queryParameters = {};
    String env = "";
    if (type == PolicyType.staging) {
      env = "staging";
    }
    if (type == PolicyType.production) {
      env = "production";
    }
    Options options = Options(
        method: 'GET',
        contentType: 'application/json',
        headers: headers,
        responseType: ResponseType.json);
    var request = await dio.get('/xc/app/$appName/$env',
        queryParameters: queryParameters, options: options);
    if (request.statusCode! > 200) {
      return ListRevisionModel(
          responseCode: request.statusCode ?? 400,
          errorMessage: request.statusMessage);
    }
    List<RevisionModel> model = [];
    for (var each in request.data) {
      Map<String, dynamic> data;
      if (each is String) {
        data = jsonDecode(each);
      } else {
        data = each;
      }
      model.add(RevisionModel.fromJson(data));
    }
    return ListRevisionModel(responseCode: 200, listRevisionModel: model);
  }

  Future<ListRevisionModel> snapshotManual(String bearer) async {
    ListRevisionModel exceptions =
        ListRevisionModel(responseCode: 401, errorMessage: "Bearer is missing");
    if (bearer.isEmpty) {
      return exceptions;
    }
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $bearer'
    };
    Options options = Options(
        method: 'POST',
        contentType: 'application/json',
        headers: headers,
        responseType: ResponseType.json);
    var request = await dio.post('/xc/snapshot/now', options: options);
    if (request.statusCode! > 201) {
      return ListRevisionModel(
          responseCode: request.statusCode ?? 400,
          errorMessage: request.statusMessage);
    }
    return ListRevisionModel(responseCode: request.statusCode ?? 201, errorMessage: "${request.data}");
  }
}
