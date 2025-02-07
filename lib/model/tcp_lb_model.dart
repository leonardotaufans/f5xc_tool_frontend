import 'package:f5xc_tool/model/main_model.dart';

class ListTcpLBVersionModel {
  final int responseCode;
  String? detail;
  List<TcpLBVersionModel>? modelList;

  ListTcpLBVersionModel(
      {required this.responseCode, this.detail, this.modelList});
}

class TcpLBVersionModel {
  String? appName;
  String? environment;
  int? timestamp;
  String? originalAppName;
  int? currentVersion;
  String? uid;

  TcpLBVersionModel(
      {this.currentVersion,
      this.appName,
      this.originalAppName,
      this.environment,
      this.timestamp,
      this.uid});

  TcpLBVersionModel.fromJson(Map<String, dynamic> json) {
    environment = json['environment'];
    uid = json['uid'];
    originalAppName = json['original_tcp_lb_name'];
    timestamp = json['timestamp'];
    appName = json['tcp_lb_name'];
    currentVersion = json['current_version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['environment'] = environment;
    data['uid'] = uid;
    data['original_tcp_lb_name'] = originalAppName;
    data['timestamp'] = timestamp;
    data['tcp_lb_name'] = appName;
    data['current_version'] = currentVersion;
    return data;
  }
}

class ListTcpLBRevisionModel {
  final int responseCode;
  String? detail;
  List<TcpLBRevisionModel>? modelList;

  ListTcpLBRevisionModel(
      {required this.responseCode, this.detail, this.modelList});
}

class TcpLBRevisionModel {
  String? uid;
  int? version;
  Map<String, dynamic>? lbConfig;
  List<dynamic>? originConfig;
  String? appName;
  String? originalAppName;
  int? timestamp;
  String? generatedBy;
  Map<String, dynamic>? wafConfig;
  String? remarks;
  int? previousVersion;
  int? lbResourceVersion;

  TcpLBRevisionModel(
      {this.uid,
      this.version,
      this.lbConfig,
      this.originConfig,
      this.appName,
      this.originalAppName,
      this.timestamp,
      this.generatedBy,
      this.wafConfig,
      this.lbResourceVersion});

  TcpLBRevisionModel.fromJson(Map<String, dynamic> json) {
    appName = json['tcp_lb_name'];
    originalAppName = json['original_tcp_lb_name'];
    version = json['version'];
    timestamp = json['timestamp'];
    lbConfig = json['lb_config'];
    remarks = json['remarks'];
    uid = json['uid'];
    generatedBy = json['generated_by'];
    previousVersion = json['previous_version'];
    lbResourceVersion = json['lb_resource_version'];
    originConfig = json['origin_config'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tcp_lb_name'] = appName;
    data['original_tcp_lb_name'] = originalAppName;
    data['version'] = version;
    data['timestamp'] = timestamp;
    if (lbConfig != null) {
      data['lb_config'] = lbConfig;
    }
    data['remarks'] = remarks;
    data['uid'] = uid;
    data['generated_by'] = generatedBy;
    data['previous_version'] = previousVersion;
    data['lb_resource_version'] = lbResourceVersion;
    if (originConfig != null) {
      data['origin_config'] = originConfig;
    }
    return data;
  }
}
