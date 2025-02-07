class ListCDNLBVersionModel {
  final int responseCode;
  String? detail;
  List<CDNLBVersionModel>? modelList;

  ListCDNLBVersionModel(
      {required this.responseCode, this.detail, this.modelList});
}

class CDNLBVersionModel {
  String? environment;
  String? uid;
  String? originalAppName;
  int? timestamp;
  String? appName;
  int? currentVersion;

  CDNLBVersionModel(
      {this.environment,
      this.uid,
      this.originalAppName,
      this.timestamp,
      this.appName,
      this.currentVersion});

  CDNLBVersionModel.fromJson(Map<String, dynamic> json) {
    environment = json['environment'];
    uid = json['uid'];
    originalAppName = json['original_cdn_lb_name'];
    timestamp = json['timestamp'];
    appName = json['cdn_lb_name'];
    currentVersion = json['current_version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['environment'] = environment;
    data['uid'] = uid;
    data['original_cdn_lb_name'] = originalAppName;
    data['timestamp'] = timestamp;
    data['cdn_lb_name'] = appName;
    data['current_version'] = currentVersion;
    return data;
  }
}

class ListCDNLBRevisionModel {
  final int responseCode;
  String? detail;
  List<CDNLBRevisionModel>? modelList;

  ListCDNLBRevisionModel(
      {required this.responseCode, this.detail, this.modelList});
}

class CDNLBRevisionModel {
  String? appName;
  String? originalAppName;
  int? version;
  int? timestamp;
  Map<dynamic, dynamic>? lbConfig;
  String? remarks;
  String? uid;
  String? generatedBy;
  int? previousVersion;
  int? lbResourceVersion;
  List<dynamic>? originConfig;
  Map<dynamic, dynamic>? wafConfig;

  CDNLBRevisionModel(
      {this.appName,
      this.originalAppName,
      this.version,
      this.timestamp,
      this.lbConfig,
      this.remarks,
      this.uid,
      this.generatedBy,
      this.previousVersion,
      this.lbResourceVersion,
      this.wafConfig,
      this.originConfig});

  CDNLBRevisionModel.fromJson(Map<String, dynamic> json) {
    appName = json['cdn_lb_name'];
    originalAppName = json['original_cdn_lb_name'];
    version = json['version'];
    timestamp = json['timestamp'];
    lbConfig = json['lb_config'];
    remarks = json['remarks'];
    uid = json['uid'];
    generatedBy = json['generated_by'];
    previousVersion = json['previous_version'];
    lbResourceVersion = json['lb_resource_version'];
    originConfig = json['origin_config'];
    wafConfig = json['waf_config'];
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
    if (wafConfig != null) {
      data['waf_config'] = wafConfig;
    }
    return data;
  }
}
