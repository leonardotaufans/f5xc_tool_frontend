class ListProductionRevisionModelHTTPLB {
  int responseCode;
  String? errorMessage;
  List<ProductionRevisionModelHTTPLB>? listRevisionModel;

  ListProductionRevisionModelHTTPLB(
      {required this.responseCode, this.errorMessage, this.listRevisionModel});
}

class ProductionRevisionModelHTTPLB {
  String? uid;
  int? version;
  String? lbConfig;
  String? originConfig;
  String? ddosConfig;
  String? appName;
  int? timestamp;
  String? generatedBy;
  String? wafConfig;
  String? botConfig;
  String? remarks;
  int? previousVersion;
  int? lbResourceVersion;

  ProductionRevisionModelHTTPLB(
      {this.uid,
      this.version,
      this.lbConfig,
      this.originConfig,
      this.ddosConfig,
      this.appName,
      this.timestamp,
      this.generatedBy,
      this.previousVersion,
      this.wafConfig,
      this.remarks,
      this.botConfig});

  ProductionRevisionModelHTTPLB.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    version = json['version'];
    lbConfig = json['lb_config'];
    originConfig = json['origin_config'];
    ddosConfig = json['ddos_config'];
    appName = json['app_name'];
    timestamp = json['timestamp'];
    generatedBy = json['generated_by'];
    wafConfig = json['waf_config'];
    botConfig = json['bot_config'];
    previousVersion = json['previous_version'];
    remarks = json['remarks'];
    lbResourceVersion = json['lb_resource_version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['version'] = version;
    data['lb_config'] = lbConfig;
    data['origin_config'] = originConfig;
    data['ddos_config'] = ddosConfig;
    data['app_name'] = appName;
    data['timestamp'] = timestamp;
    data['generated_by'] = generatedBy;
    data['waf_config'] = wafConfig;
    data['bot_config'] = botConfig;
    data['remarks'] = remarks;
    data['previous_version'] = previousVersion;
    return data;
  }
}

class ListRevisionModelHTTPLB {
  int responseCode;
  String? errorMessage;
  List<RevisionModelHTTPLB>? listRevisionModel;

  ListRevisionModelHTTPLB(
      {required this.responseCode, this.errorMessage, this.listRevisionModel});
}

class RevisionModelHTTPLB {
  String? uid;
  int? version;
  Map<String, dynamic>? lbConfig;
  List<dynamic>? originConfig;
  Map<dynamic, dynamic>? ddosConfig;
  String? appName;
  String? originalAppName;
  int? timestamp;
  String? generatedBy;
  Map<String, dynamic>? wafConfig;
  Map<dynamic, dynamic>? botConfig;
  String? remarks;
  int? previousVersion;

  RevisionModelHTTPLB(
      {this.uid,
      this.version,
      this.lbConfig,
      this.originConfig,
      this.ddosConfig,
      this.appName,
      this.originalAppName,
      this.timestamp,
      this.generatedBy,
      this.wafConfig,
      this.botConfig,
      this.remarks,
      this.previousVersion});

  RevisionModelHTTPLB.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    version = json['version'];
    lbConfig = json['lb_config'];
    originConfig = json['origin_config'];
    ddosConfig = json['ddos_config'];
    appName = json['app_name'];
    timestamp = json['timestamp'];
    generatedBy = json['generated_by'];
    wafConfig = json['waf_config'];
    botConfig = json['bot_config'];
    originalAppName = json['original_app_name'];
    remarks = json['remarks'];
    previousVersion = json['previous_version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['version'] = version;
    data['lb_config'] = lbConfig;
    data['origin_config'] = originConfig;
    data['ddos_config'] = ddosConfig;
    data['app_name'] = appName;
    data['timestamp'] = timestamp;
    data['generated_by'] = generatedBy;
    data['waf_config'] = wafConfig;
    data['bot_config'] = botConfig;
    data['original_app_name'] = originalAppName;
    data['previous_version'] = previousVersion;
    data['remarks'] = remarks;
    return data;
  }
}
