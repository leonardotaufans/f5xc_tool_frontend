import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/http_lb_revision_model.dart';
import 'package:f5xc_tool/model/http_lb_version_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ReplaceVersionDialog extends StatelessWidget {
  const ReplaceVersionDialog(
      {super.key,
      required this.data,
      required this.model,
      required this.policyType});

  final RevisionModelHTTPLB data;
  final HttpLBVersionModel model;
  final PolicyType policyType;

  @override
  Widget build(BuildContext context) {
    String policy =
        policyType == PolicyType.production ? "production" : "staging";
    return StatefulBuilder(builder: (BuildContext context, StateSetter setter) {
      return AlertDialog(
        title: Text('Replace Version'),
        content: Text(
            'Replace version ${data.appName}:$policy version ${model.currentVersion} with ${data.version}.\nAre you sure?'),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) {
                    startReplacePolicy(
                            data.appName ?? "", policy, data.version ?? 0)
                        .catchError((onError) {
                      if (context.mounted) {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Text('Error'),
                                content: Text('$onError'),
                                actions: [
                                  TextButton(
                                    child: Text('Close'),
                                    onPressed: () => Navigator.pop(context),
                                  )
                                ],
                              );
                            });
                      }
                    }).then((onValue) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    });
                    return AlertDialog(
                      title: Text('Replace Policy'),
                      content: Flex(
                        direction: Axis.horizontal,
                        children: [
                          SizedBox(
                              width: 64,
                              height: 64,
                              child: CircularProgressIndicator()),
                          SizedBox(
                            width: 16,
                          ),
                          Expanded(
                              flex: 3,
                              child: Text(
                                  'Please wait...\nRefresh the table once this request is completed.'))
                        ],
                      ),
                    );
                  });
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('No'),
          )
        ],
      );
    });
  }

  Future<void> startReplacePolicy(
      String appName, String environment, int targetVersion) async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    return SqlQueryHelper()
        .replaceHttpPolicy(bearer, appName, environment, targetVersion);
  }
}
