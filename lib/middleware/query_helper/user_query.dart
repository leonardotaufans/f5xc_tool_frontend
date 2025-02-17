import 'package:dio/dio.dart';
import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/generic_model.dart';
import 'package:f5xc_tool/model/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserQueryHelper {
  Dio dio = Dio(BaseOptions(
      baseUrl: Configuration().middlewareHost,
      validateStatus: (_) => true,
      receiveDataWhenStatusError: true));

  Future<NoResponseModel> createUser(UserCreate model) async {
    String bearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    if (!await SqlQueryHelper().checkAuth(bearer)) {
      await SqlQueryHelper().refreshToken();
      bearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    }
    try {
      Map<String, dynamic> headers = {"Authorization": "Bearer $bearer"};
      Map<String, dynamic> body = model.toJson();
      Options options = Options(
          contentType: 'application/json', headers: headers, method: 'POST');
      var request =
          await dio.post('/mgmt/users', options: options, data: body);
      if ((request.statusCode ?? 400) > 200) {
        return NoResponseModel(
            statusCode: request.statusCode ?? 400,
            statusMessage: request.statusMessage);
      }
      return NoResponseModel(
          statusCode: request.statusCode ?? 400,
          statusMessage: "Submitted successfully.");
    } on DioException catch (e) {
      return NoResponseModel(
          statusCode: e.response?.statusCode ?? 400, statusMessage: e.message);
    }
  }

  Future<NoResponseModel> updateUser(
      {required String position,
      required String username,
      required String valueChanged}) async {
    String bearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    if (!await SqlQueryHelper().checkAuth(bearer)) {
      await SqlQueryHelper().refreshToken();
      bearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    }
    try {
      Map<String, dynamic> headers = {"Authorization": "Bearer $bearer"};
      Map<String, dynamic> body = {
        "username": username,
        position: valueChanged
      };
      Options options = Options(
          contentType: 'application/json', headers: headers, method: 'PATCH');
      var request =
          await dio.patch('/mgmt/users', options: options, data: body);
      if ((request.statusCode ?? 400) > 200) {
        return NoResponseModel(
            statusCode: request.statusCode ?? 400,
            statusMessage: request.statusMessage);
      }
      return NoResponseModel(
          statusCode: request.statusCode ?? 400,
          statusMessage: "Submitted successfully.");
    } on DioException catch (e) {
      return NoResponseModel(
          statusCode: e.response?.statusCode ?? 400, statusMessage: e.message);
    }
  }
}
