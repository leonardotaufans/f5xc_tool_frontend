import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/model/auth_model.dart';
import 'package:f5xc_tool/model/cdn_lb_model.dart';
import 'package:f5xc_tool/model/event_log_model.dart';
import 'package:f5xc_tool/model/login_model.dart';
import 'package:f5xc_tool/model/http_lb_revision_model.dart';
import 'package:f5xc_tool/model/model_compare.dart';
import 'package:f5xc_tool/model/snapshot_model.dart';
import 'package:f5xc_tool/model/tcp_lb_model.dart';
import 'package:f5xc_tool/model/user_model.dart';
import 'package:f5xc_tool/model/http_lb_version_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SqlQueryHelper {
  Dio dio = Dio(BaseOptions(
      baseUrl: Configuration().middlewareHost,
      validateStatus: (_) => true,
      receiveDataWhenStatusError: true));
  int maxRetries = 3;

  // Login
  Future<LoginResult> login(String username, String rawPassword) async {
    FormData requestBody =
        FormData.fromMap({"username": username, "password": rawPassword});

    BaseOptions options = BaseOptions(
        baseUrl: Configuration().middlewareHost,
        contentType: 'application/json',
        method: 'POST');
    Dio dio = Dio(options);
    try {
      var req = await dio.post('/mgmt/login', data: requestBody);
      return LoginResult(
          responseCode: 200, loginData: LoginModel.fromJson(req.data));
    } on DioException catch (e) {
      return LoginResult(
          responseCode: e.response?.statusCode ?? 400,
          description: e.response?.data ?? e.error);
    }
  }

  Future<LoginResult> refreshToken() async {
    var storage = FlutterSecureStorage();
    String oldToken = await storage.read(key: 'auth') ?? "";

    Map<String, String> header = {
      HttpHeaders.authorizationHeader: "Bearer $oldToken"
    };
    Options options = Options(
        contentType: 'application/json',
        headers: header,
        method: 'POST');
    try {
      var req = await dio.post('/mgmt/user/refresh', options: options);
      LoginModel model = LoginModel.fromJson(req.data);
      await storage.write(key: 'auth', value: model.accessToken ?? "");
      return LoginResult(
          responseCode: 200, loginData: LoginModel.fromJson(req.data));
    } on DioException {
      LoginResult exception = LoginResult(
          responseCode: 401,
          description: {"error": "Username/password is incorrect"});
      return exception;
    }
  }

  Future<UserResponse> getMyself(String bearer) async {
    UserResponse exception =
        UserResponse(statusCode: 401, message: "Bearer invalid or empty.");
    try {
      if (bearer.isEmpty) {
        return exception;
      }
      Map<String, String> header = {
        HttpHeaders.authorizationHeader: "Bearer $bearer"
      };
      var request =
          await dio.post('/mgmt/get-myself', options: Options(headers: header));
      if (request.statusCode! > 200) {
        return UserResponse(
            statusCode: request.statusCode ?? 400,
            message: request.statusMessage);
      } else {
        Map<String, dynamic> response = request.data;
        return UserResponse(
            statusCode: 200, model: UserModel.fromJson(response));
      }
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.badResponse:
          if (e.response!.statusCode == 401) {
            for (int i = 0; i < maxRetries; i++) {
              refreshToken().then((val) {
                getMyself(bearer);
              });
            }
          }
          return exception;
        default:
          return exception;
      }
    }
  }

  Future<ListUserResponse> getUsers(String bearer) async {
    ListUserResponse exception =
        ListUserResponse(statusCode: 401, message: "Bearer invalid or empty.");
    try {
      if (bearer.isEmpty) {
        return exception;
      }
      Map<String, String> header = {
        HttpHeaders.authorizationHeader: "Bearer $bearer"
      };
      var request =
          await dio.get('/mgmt/users', options: Options(headers: header));
      if (request.statusCode! > 200) {
        return ListUserResponse(
            statusCode: request.statusCode ?? 400,
            message: request.statusMessage);
      } else {
        List<UserModel> model = [];
        for (var each in request.data) {
          model.add(UserModel.fromJson(each));
        }
        return ListUserResponse(statusCode: 200, userList: model);
      }
    } on DioException {
      return exception;
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

  Future<ListRevisionModelHTTPLB> getAllHttpRevisions(
      String bearer, String appName, PolicyType type) async {
    ListRevisionModelHTTPLB exceptions = ListRevisionModelHTTPLB(
        responseCode: 401, errorMessage: "Bearer is missing");
    if (bearer.isEmpty) {
      return exceptions;
    }
    if (appName.isEmpty) {
      return ListRevisionModelHTTPLB(
          responseCode: 400, errorMessage: "App name is missing");
    }
    String newBearer = bearer;
    if (!await checkAuth(newBearer)) {
      await refreshToken();
      newBearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    }

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $newBearer'
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
    var request = await dio.get('/xc/http-lb/$appName/$env',
        queryParameters: queryParameters, options: options);
    if (request.statusCode! > 200) {
      return ListRevisionModelHTTPLB(
          responseCode: request.statusCode ?? 400,
          errorMessage: request.statusMessage);
    }
    List<RevisionModelHTTPLB> model = [];
    for (var each in request.data) {
      Map<String, dynamic> data;
      if (each is String) {
        data = jsonDecode(each);
      } else {
        data = each;
      }
      model.add(RevisionModelHTTPLB.fromJson(data));
    }
    return ListRevisionModelHTTPLB(responseCode: 200, listRevisionModel: model);
  }

  Future<ListHttpLBVersionModel> getHttpVersion(
      PolicyType type, String bearer) async {
    ListHttpLBVersionModel exception = ListHttpLBVersionModel(
        responseCode: 401, error: "You are not authenticated!");
    if (bearer.isEmpty) {
      return exception;
    }
    String newBearer = bearer;
    if (!await checkAuth(newBearer)) {
      await refreshToken();
      newBearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    }

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $newBearer'
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
    var request = await dio.get('/xc/http-lb',
        queryParameters: queryParameters, options: options);
    // print(request.data.toString());
    if (request.statusCode! > 200) {
      return ListHttpLBVersionModel(
          responseCode: request.statusCode ?? 400,
          error: request.statusMessage);
    } else {
      List<HttpLBVersionModel> data = [];
      for (var each in request.data) {
        data.add(HttpLBVersionModel.fromJson(each));
      }
      return ListHttpLBVersionModel(responseCode: 200, versionData: data);
    }
  }

  Future<ListTcpLBVersionModel> getTcpVersion(
      PolicyType type, String bearer) async {
    ListTcpLBVersionModel exception = ListTcpLBVersionModel(
        responseCode: 401, detail: "You are not authenticated!");
    if (bearer.isEmpty) {
      return exception;
    }
    String newBearer = bearer;
    if (!await checkAuth(newBearer)) {
      await refreshToken();
      newBearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    }

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $newBearer'
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
    var request = await dio.get('/xc/tcp-lb',
        queryParameters: queryParameters, options: options);
    // print(request.data.toString());
    if (request.statusCode! > 200) {
      return ListTcpLBVersionModel(
          responseCode: request.statusCode ?? 400,
          detail: request.statusMessage);
    } else {
      List<TcpLBVersionModel> data = [];
      for (var each in request.data) {
        data.add(TcpLBVersionModel.fromJson(each));
      }
      return ListTcpLBVersionModel(responseCode: 200, modelList: data);
    }
  }

  Future<ListTcpLBRevisionModel> getAllTcpRevisions(
      String bearer, String appName, PolicyType type) async {
    ListTcpLBRevisionModel exceptions =
        ListTcpLBRevisionModel(responseCode: 401, detail: "Bearer is missing");
    if (bearer.isEmpty) {
      return exceptions;
    }
    if (appName.isEmpty) {
      return ListTcpLBRevisionModel(
          responseCode: 400, detail: "App name is missing");
    }
    String newBearer = bearer;
    if (!await checkAuth(newBearer)) {
      await refreshToken();
      newBearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    }

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $newBearer'
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
    var request = await dio.get('/xc/tcp-lb/$appName/$env',
        queryParameters: queryParameters, options: options);
    if (request.statusCode! > 200) {
      return ListTcpLBRevisionModel(
          responseCode: request.statusCode ?? 400,
          detail: request.statusMessage);
    }
    List<TcpLBRevisionModel> model = [];
    for (var each in request.data) {
      Map<String, dynamic> data;
      if (each is String) {
        data = jsonDecode(each);
      } else {
        data = each;
      }
      model.add(TcpLBRevisionModel.fromJson(data));
    }
    return ListTcpLBRevisionModel(responseCode: 200, modelList: model);
  }

  Future<ListCDNLBVersionModel> getCDNVersion(
      PolicyType type, String bearer) async {
    ListCDNLBVersionModel exception = ListCDNLBVersionModel(
        responseCode: 401, detail: "You are not authenticated!");
    if (bearer.isEmpty) {
      return exception;
    }
    String newBearer = bearer;
    if (!await checkAuth(newBearer)) {
      await refreshToken();
      newBearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    }

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $newBearer'
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
    var request = await dio.get('/xc/cdn-lb',
        queryParameters: queryParameters, options: options);
    // print(request.data.toString());
    if (request.statusCode! > 200) {
      return ListCDNLBVersionModel(
          responseCode: request.statusCode ?? 400,
          detail: request.statusMessage);
    } else {
      List<CDNLBVersionModel> data = [];
      for (var each in request.data) {
        data.add(CDNLBVersionModel.fromJson(each));
      }
      return ListCDNLBVersionModel(responseCode: 200, modelList: data);
    }
  }

  Future<ListCDNLBRevisionModel> getAllCDNRevisions(
      String bearer, String appName, PolicyType type) async {
    ListCDNLBRevisionModel exceptions =
        ListCDNLBRevisionModel(responseCode: 401, detail: "Bearer is missing");
    if (bearer.isEmpty) {
      return exceptions;
    }
    if (appName.isEmpty) {
      return ListCDNLBRevisionModel(
          responseCode: 400, detail: "App name is missing");
    }
    String newBearer = bearer;
    if (!await checkAuth(newBearer)) {
      await refreshToken();
      newBearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    }

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $newBearer'
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
    var request = await dio.get('/xc/cdn-lb/$appName/$env',
        queryParameters: queryParameters, options: options);
    if (request.statusCode! > 200) {
      return ListCDNLBRevisionModel(
          responseCode: request.statusCode ?? 400,
          detail: request.statusMessage);
    }
    List<CDNLBRevisionModel> model = [];
    for (var each in request.data) {
      Map<String, dynamic> data;
      if (each is String) {
        data = jsonDecode(each);
      } else {
        data = each;
      }
      model.add(CDNLBRevisionModel.fromJson(data));
    }
    return ListCDNLBRevisionModel(responseCode: 200, modelList: model);
  }

  // Snapshot
  Future<SnapshotResult> snapshotManual(String bearer) async {
    SnapshotResult exceptions =
        SnapshotResult(responseCode: 401, detail: "Bearer is missing");
    if (bearer.isEmpty) {
      return exceptions;
    }
    String newBearer = bearer;
    if (!await checkAuth(newBearer)) {
      await refreshToken();
      newBearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    }

    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $newBearer'
    };
    Options options = Options(
        method: 'POST',
        contentType: 'application/json',
        headers: headers,
        responseType: ResponseType.json);
    var request = await dio.post('/xc/snapshot/now',
        options:
            options);
    if (request.statusCode! > 201) {
      return SnapshotResult(
          responseCode: request.statusCode ?? 400,
          detail: request.statusMessage);
    }
    return SnapshotResult(
        responseCode: request.statusCode ?? 201,
        detail: 'Snapshot result',
        snapshot: SnapshotModel.fromJson(request.data));
  }

  Future<void> replaceHttpPolicy(String bearer, String appName,
      String environment, int targetVersion) async {
    try {
      if (bearer.isEmpty || appName.isEmpty || environment.isEmpty) {
        throw Exception("Value is missing");
      }
      String newBearer = bearer;
      if (!await checkAuth(newBearer)) {
        await refreshToken();
        newBearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
      }

      Map<String, String> headers = {
        HttpHeaders.authorizationHeader: 'Bearer $newBearer'
      };
      Map<String, dynamic> body = {
        "app_name": appName,
        "environment": environment,
        "target_version": targetVersion
      };
      Options options = Options(
          method: 'POST',
          contentType: 'application/json',
          headers: headers,
          responseType: ResponseType.json);
      var request = await dio.post('/xc/http-lb/replace-version',
          options: options, data: body);
      if ((request.statusCode ?? 400) > 200) {
        throw Exception(request.data);
      }
    } on DioException catch (_, e) {
      throw Exception(e);
    }
  }

  Future<void> replaceTcpPolicy(String bearer, String appName,
      String environment, int targetVersion) async {
    try {
      if (bearer.isEmpty || appName.isEmpty || environment.isEmpty) {
        throw Exception("Value is missing");
      }
      String newBearer = bearer;
      if (!await checkAuth(newBearer)) {
        await refreshToken();
        newBearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
      }

      Map<String, String> headers = {
        HttpHeaders.authorizationHeader: 'Bearer $newBearer'
      };
      Map<String, dynamic> body = {
        "app_name": appName,
        "environment": environment,
        "target_version": targetVersion
      };
      Options options = Options(
          method: 'POST',
          contentType: 'application/json',
          headers: headers,
          responseType: ResponseType.json);
      var request = await dio.post('/xc/tcp-lb/replace-version',
          options: options, data: body);
      if ((request.statusCode ?? 400) > 200) {
        throw Exception(request.data);
      }
    } on DioException catch (_, e) {
      throw Exception(e);
    }
  }

  Future<CompareModel> compareVersion(
      String bearer,
      LoadBalancerType lbType,
      String prevAppName,
      String prevEnvironment,
      int prevVersion,
      String newAppName,
      String newEnvironment,
      int newVersion) async {
    String path = "http-lb";
    switch (lbType) {
      case LoadBalancerType.http:
        path = "http-lb";
        break;
      case LoadBalancerType.cdn:
        path = "cdn-lb";
        break;
      case LoadBalancerType.tcp:
        path = "tcp-lb";
        break;
    }
    try {
      if (bearer.isEmpty) {
        throw Exception("You are not logged in?");
      }
      Map<String, dynamic> queryParams = {};
      String newBearer = bearer;
      if (!await checkAuth(newBearer)) {
        await refreshToken();
        newBearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
      }

      Map<String, String> headers = {
        HttpHeaders.authorizationHeader: 'Bearer $newBearer'
      };
      queryParams.addAll({
        "new_app_name": newAppName,
        "new_environment": newEnvironment,
        "new_version": newVersion,
        "old_app_name": prevAppName,
        "old_environment": prevEnvironment,
        "old_version": prevVersion
      });
      Options options = Options(
          method: 'GET',
          contentType: 'application/json',
          headers: headers,
          responseType: ResponseType.json);

      var request = await dio.get("/xc/$path/compare-version",
          queryParameters: queryParams, options: options);
      if ((request.statusCode ?? 400) > 200) {
        return CompareModel();
      }
      return CompareModel.fromJson(request.data);
    } on DioException {
      return CompareModel();
    }
  }

  Future<void> replaceCDNPolicy(String bearer, String appName,
      String environment, int targetVersion) async {
    try {
      if (bearer.isEmpty || appName.isEmpty || environment.isEmpty) {
        throw Exception("Value is missing");
      }
      String newBearer = bearer;
      if (!await checkAuth(newBearer)) {
        await refreshToken();
        newBearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
      }

      Map<String, String> headers = {
        HttpHeaders.authorizationHeader: 'Bearer $newBearer'
      };
      Map<String, dynamic> body = {
        "app_name": appName,
        "environment": environment,
        "target_version": targetVersion
      };
      Options options = Options(
          method: 'POST',
          contentType: 'application/json',
          headers: headers,
          responseType: ResponseType.json);
      var request = await dio.post('/xc/cdn-lb/replace-version',
          options: options, data: body);
      if ((request.statusCode ?? 400) > 200) {
        throw Exception(request.data);
      }
    } on DioException catch (_, e) {
      throw Exception(e);
    }
  }

  Future<bool> checkAuth(String bearer) async {
    try {
      Map<String, String> headers = {
        HttpHeaders.authorizationHeader: 'Bearer $bearer'
      };
      Options options = Options(
          method: 'POST',
          contentType: 'application/json',
          headers: headers,
          responseType: ResponseType.json);
      var request = await dio.post('/test/token', options: options);
      if (request.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } on DioException {
      return false;
    }
  }

  Future<String> comparePolicy(
      String bearer,
      String path,
      String oldName,
      int oldVer,
      String oldType,
      String newName,
      int newVer,
      String newType) async {
    // attempts to refresh token if expired mid-execution
    String testBearer = bearer;
    if (!await checkAuth(testBearer)) {
      var user = await refreshToken();
      testBearer = user.loginData?.accessToken ?? "";
    }
    Map<String, dynamic> query = {
      "new_app_name": newName,
      "new_version": newVer,
      "new_environment": newType,
      "old_app_name": oldName,
      "old_environment": oldType,
      "old_version": oldVer
    };
    try {
      String newBearer = bearer;
      if (!await checkAuth(newBearer)) {
        await refreshToken();
        newBearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
      }

      Map<String, String> headers = {
        HttpHeaders.authorizationHeader: 'Bearer $newBearer'
      };

      Options options = Options(
          method: 'GET',
          contentType: 'application/json',
          headers: headers,
          responseType: ResponseType.json);
      var request = await dio.get('/xc/$path/compare-version',
          queryParameters: query, options: options);
      return jsonEncode(request.data);
    } on DioException {
      return "";
    }
  }

  Future<ListEventLogModel> getEventLogs(String bearer) async {
    // attempts to refresh token if expired mid-execution
    String refreshBearer = bearer;
    if (!await checkAuth(refreshBearer)) {
      var user = await refreshToken();
      refreshBearer = user.loginData?.accessToken ?? '';
    }
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $refreshBearer'
    };
    try {
      Options options = Options(
          method: 'GET',
          contentType: 'application/json',
          headers: headers,
          responseType: ResponseType.json);
      var request = await dio.get('/xc/logs', options: options);
      List<EventLogModel> model = [];
      for (var each in request.data) {
        model.add(EventLogModel.fromJson(each));
      }
      return ListEventLogModel(
          responseCode: request.statusCode ?? 200, eventLogs: model);
    } on DioException catch (e) {
      return ListEventLogModel(responseCode: e.response?.statusCode ?? 400);
    }
  }

  void snapshotRemarks(String bearer, String uid, String environment,
      String path, String remarks) async {
    String refreshBearer = bearer;
    if (!await checkAuth(refreshBearer)) {
      var user = await refreshToken();
      refreshBearer = user.loginData?.accessToken ?? '';
    }
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $refreshBearer'
    };
    Options options = Options(
        method: 'PUT',
        contentType: 'application/json',
        headers: headers,
        responseType: ResponseType.json);
    Map<String, String> queryParameter = {
      "uid": uid,
      "environment": environment,
      "lb_type": path,
      "remarks": remarks
    };
    try {
      await dio.put('/xc/snapshot/remarks',
          data: queryParameter, options: options); // still in demo
    } on DioException {
      throw Exception();
    }
  }
}
