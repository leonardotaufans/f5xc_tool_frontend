class ListHttpLBVersionModel {
  int responseCode;
  String? error;
  List<HttpLBVersionModel>? versionData;

  ListHttpLBVersionModel(
      {required this.responseCode, this.error, this.versionData});
}

class HttpLBVersionModel {
  String? appName;
  String? environment;
  int? timestamp;
  int? currentVersion;
  String? uid;

  HttpLBVersionModel(
      {this.appName,
      this.environment,
      this.timestamp,
      this.currentVersion,
      this.uid});

  HttpLBVersionModel.fromJson(Map<String, dynamic> json) {
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
