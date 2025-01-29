class ListProductionRevisionModel {
  int responseCode;
  String? errorMessage;
  List<ProductionRevisionModel>? listRevisionModel;

  ListProductionRevisionModel(
      {required this.responseCode, this.errorMessage, this.listRevisionModel});
}

class ProductionRevisionModel {
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

  ProductionRevisionModel(
      {this.uid,
        this.version,
        this.lbConfig,
        this.originConfig,
        this.ddosConfig,
        this.appName,
        this.timestamp,
        this.generatedBy,
        this.wafConfig,
        this.botConfig});

  ProductionRevisionModel.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}



class ListRevisionModel {
  int responseCode;
  String? errorMessage;
  List<RevisionModel>? listRevisionModel;

  ListRevisionModel(
      {required this.responseCode, this.errorMessage, this.listRevisionModel});
}

class RevisionModel {
  String? uid;
  int? version;
  Map<String, dynamic>? lbConfig;
  List<dynamic>? originConfig;
  Map<dynamic, dynamic>? ddosConfig;
  String? appName;
  int? timestamp;
  String? generatedBy;
  Map<String, dynamic>? wafConfig;
  Map<dynamic, dynamic>? botConfig;

  RevisionModel(
      {this.uid,
      this.version,
      this.lbConfig,
      this.originConfig,
      this.ddosConfig,
      this.appName,
      this.timestamp,
      this.generatedBy,
      this.wafConfig,
      this.botConfig});

  RevisionModel.fromJson(Map<String, dynamic> json) {
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
    return data;
  }
}
