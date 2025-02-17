class ListEventLogModel {
  final int responseCode;
  final String? detail;
  final List<EventLogModel>? eventLogs;

  ListEventLogModel({required this.responseCode, this.detail, this.eventLogs});
}

class EventLogModel {
  int? timestamp;
  String? user;
  int? previousVersion;
  int? uid;
  String? description;
  String? environment;
  String? eventType;
  int? targetVersion;

  EventLogModel(
      {this.timestamp,
      this.user,
      this.previousVersion,
      this.uid,
      this.description,
      this.environment,
      this.eventType,
      this.targetVersion});

  EventLogModel.fromJson(Map<String, dynamic> json) {
    timestamp = json['timestamp'];
    user = json['user'];
    previousVersion = json['previous_version'];
    uid = json['uid'];
    description = json['description'];
    environment = json['environment'];
    eventType = json['event_type'];
    targetVersion = json['target_version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timestamp'] = timestamp;
    data['user'] = user;
    data['previous_version'] = previousVersion;
    data['uid'] = uid;
    data['description'] = description;
    data['environment'] = environment;
    data['event_type'] = eventType;
    data['target_version'] = targetVersion;
    return data;
  }
}
