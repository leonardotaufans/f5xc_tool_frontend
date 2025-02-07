class CompareModel {
  Map<dynamic, dynamic>? rootDifference;
  Map<dynamic, dynamic>? lbDifference;
  Map<dynamic, dynamic>? originDifference;
  Map<dynamic, dynamic>? wafDifference;

  CompareModel(
      {this.rootDifference,
      this.lbDifference,
      this.originDifference,
      this.wafDifference});

  CompareModel.fromJson(Map<dynamic, dynamic> json) {
    rootDifference = json['root_difference'];
    originDifference = json['origin_difference'];
    lbDifference = json['lb_difference'];
    wafDifference = json['waf_difference'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['root_difference'] = rootDifference;
    data['origin_difference'] = originDifference;
    data['lb_difference'] = lbDifference;
    data['waf_difference'] = wafDifference;
    return data;
  }
}
