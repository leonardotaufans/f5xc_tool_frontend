class SnapshotResult {
  final int responseCode;
  final String? detail;
  final SnapshotModel? snapshot;

  SnapshotResult({required this.responseCode, this.detail, this.snapshot});
}

class SnapshotModel {
  SnapshotModel({
    required this.result,
    this.httpLb,
    this.tcpLb,
    this.cdnLb,
  });

  final String? result;
  final LoadBalancer? httpLb;
  final LoadBalancer? tcpLb;
  final LoadBalancer? cdnLb;

  factory SnapshotModel.fromJson(Map<String, dynamic> json) {
    return SnapshotModel(
      result: json["result"],
      httpLb: json["http_lb"] == null
          ? null
          : LoadBalancer.fromJson(json["http_lb"]),
      tcpLb:
          json["tcp_lb"] == null ? null : LoadBalancer.fromJson(json["tcp_lb"]),
      cdnLb:
          json["cdn_lb"] == null ? null : LoadBalancer.fromJson(json["cdn_lb"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "result": result,
        "http_lb": httpLb?.toJson(),
        "tcp_lb": tcpLb?.toJson(),
        "cdn_lb": cdnLb?.toJson(),
      };
}

class LoadBalancer {
  LoadBalancer({
    this.newProd,
    this.newStaging,
    this.updateProd,
    this.updateStaging,
  });

  final List<SnapshotContents>? newProd;
  final List<SnapshotContents>? newStaging;
  final List<SnapshotContents>? updateProd;
  final List<SnapshotContents>? updateStaging;

  factory LoadBalancer.fromJson(Map<String, dynamic> json) {
    return LoadBalancer(
      newProd: json["new_prod"] == null
          ? []
          : List<SnapshotContents>.from(
              json["new_prod"]!.map((x) => SnapshotContents.fromJson(x))),
      newStaging: json["new_staging"] == null
          ? []
          : List<SnapshotContents>.from(
              json["new_staging"]!.map((x) => SnapshotContents.fromJson(x))),
      updateProd: json["update_prod"] == null
          ? []
          : List<SnapshotContents>.from(
              json["update_prod"]!.map((x) => SnapshotContents.fromJson(x))),
      updateStaging: json["update_staging"] == null
          ? []
          : List<SnapshotContents>.from(
              json["update_staging"]!.map((x) => SnapshotContents.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "new_prod": newProd?.map((x) => x.toJson()).toList(),
        "new_staging": newStaging?.map((x) => x.toJson()).toList(),
        "update_prod": updateProd?.map((x) => x.toJson()).toList(),
        "update_staging": updateStaging?.map((x) => x.toJson()).toList(),
      };
}

class SnapshotContents {
  SnapshotContents({
    required this.name,
    required this.newVersion,
    required this.uid,
    required this.previousVersion,
  });

  final String? name;
  final int? newVersion;
  final String? uid;
  final int? previousVersion;

  factory SnapshotContents.fromJson(Map<String, dynamic> json) {
    return SnapshotContents(
      name: json["name"],
      newVersion: json["new_version"],
      uid: json["uid"],
      previousVersion: json["previous_version"],
    );
  }

  Map<String, dynamic> toJson() => {
        "name": name,
        "new_version": newVersion,
        "uid": uid,
        "previous_version": previousVersion,
      };
}
