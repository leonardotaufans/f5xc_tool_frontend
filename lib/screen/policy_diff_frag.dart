import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fsoft_diff_patch/fsoft_diff_patch.dart';

class PolicyDiffFrag extends StatelessWidget {
  const PolicyDiffFrag({super.key});

  final String jsonOne =
      '{\n  "name": "leo",\n  "version": 1,\n  "uid": 12345678,\n  "echo": true,\n  '
      '"contents": {\n    "stockName": "sempak superman",\n    "condition": "used",\n    "price": 25000\n  }}';
  final String jsonTwo =
      '{\n  "name": "tomang",\n  "version": 2,\n  "uid": 12345679,\n  '
      '"contents": {\n    "stockName": "sempak superman",\n    "condition": "new",\n    "price": 250000\n  }}';

  @override
  Widget build(BuildContext context) {
    final diffData = diff(json.decode(jsonOne), json.decode(jsonTwo));
    print('diff: $diffData');
    return const Placeholder();
  }
}

class OwO {
  String? name;
  int? version;
  int? uid;
  bool? echo;
  Contents? contents;

  OwO({this.name, this.version, this.uid, this.echo, this.contents});

  OwO.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    version = json['version'];
    uid = json['uid'];
    echo = json['echo'];
    contents =
        json['contents'] != null ? Contents.fromJson(json['contents']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['version'] = version;
    data['uid'] = uid;
    data['echo'] = echo;
    if (contents != null) {
      data['contents'] = contents!.toJson();
    }
    return data;
  }
}

class Contents {
  String? stockName;
  String? condition;
  int? price;

  Contents({this.stockName, this.condition, this.price});

  Contents.fromJson(Map<String, dynamic> json) {
    stockName = json['stockName'];
    condition = json['condition'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stockName'] = stockName;
    data['condition'] = condition;
    data['price'] = price;
    return data;
  }
}
