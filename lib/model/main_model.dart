class ListVersionModel {
  final int responseCode;
  String? detail;
  List<VersionModel>? modelList;

  ListVersionModel({required this.responseCode, this.detail, this.modelList});
}

class VersionModel {
  String? appName;
  String? environment;
  int? timestamp;
  String? originalAppName;
  int? currentVersion;
  String? uid;

  VersionModel(
      {this.currentVersion,
      this.appName,
      this.originalAppName,
      this.environment,
      this.timestamp,
      this.uid});
}

class ListRevisionModel {
  final int responseCode;
  String? detail;
  List<RevisionModel>? modelList;

  ListRevisionModel({required this.responseCode, this.detail, this.modelList});
}

class RevisionModel {
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
  int? lbResourceVersion;

  RevisionModel(
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
      this.lbResourceVersion,
      this.botConfig});
}
