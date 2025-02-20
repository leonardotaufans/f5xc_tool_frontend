import 'dart:convert';

import 'package:code_text_field/code_text_field.dart';
import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/model_compare.dart';
import 'package:f5xc_tool/model/tcp_lb_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/languages/json.dart';

class TCPChangesDialog extends StatefulWidget {
  final TcpLBRevisionModel revision;
  final String environment;

  const TCPChangesDialog(
      {super.key, required this.revision, required this.environment});

  @override
  State<TCPChangesDialog> createState() => _TCPChangesDialogState();
}

class _TCPChangesDialogState extends State<TCPChangesDialog> {
  late CodeController _codeController = CodeController();

  String getPrettyJsonString(jsonObject) {
    var encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonObject);
  }

  Future<CompareModel> getTCPComparison(TcpLBRevisionModel revision) async {
    int prevVersion = revision.previousVersion ?? ((revision.version ?? 1) - 1);
    if (prevVersion <= 1) {
      return CompareModel(
          lbDifference: {},
          originDifference: {},
          rootDifference: {},
          wafDifference: {});
    }
    String bearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    CompareModel compare = await SqlQueryHelper().compareVersion(
        bearer,
        LoadBalancerType.tcp,
        revision.appName ?? "",
        widget.environment,
        prevVersion,
        revision.appName ?? "",
        widget.environment,
        revision.version ?? 1);
    return compare;
  }

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: '{}',
      language: json,
    );
    getTCPComparison(widget.revision).then((val) {
      Map<String, dynamic> valMap = {
        "root_difference": val.rootDifference ?? {},
        "lb_difference": val.lbDifference ?? {},
        "origin_difference": val.originDifference ?? {},
        "waf_difference": val.wafDifference ?? {}
      };
      setState(() {
        _codeController.text = getPrettyJsonString(valMap);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CodeTheme(
      data: CodeThemeData(styles: monokaiSublimeTheme),
      child: CodeField(
        textStyle: GoogleFonts.sourceCodePro(),
        controller: _codeController,
        readOnly: true,
      ),
    );
  }
}
