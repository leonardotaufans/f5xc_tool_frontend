class ListVersionModel {
  int responseCode;
  String? error;
  List<VersionModel>? versionData;

  ListVersionModel(
      {required this.responseCode, this.error, this.versionData});
}

class VersionModel {
  String? appName;
  String? environment;
  int? timestamp;
  int? currentVersion;
  String? uid;

  VersionModel(
      {this.appName,
      this.environment,
      this.timestamp,
      this.currentVersion,
      this.uid});

  VersionModel.fromJson(Map<String, dynamic> json) {
    appName = json['app_name'];
    environment = json['environment'];
    timestamp = json['timestamp'];
    currentVersion = json['current_version'];
    uid = json['uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['app_name'] = appName;
    data['environment'] = environment;
    data['timestamp'] = timestamp;
    data['current_version'] = currentVersion;
    data['uid'] = uid;
    return data;
  }
}
