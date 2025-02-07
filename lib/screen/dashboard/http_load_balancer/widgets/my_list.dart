import 'package:code_text_field/code_text_field.dart';
import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/request_helper.dart';
import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/http_lb_revision_model.dart';
import 'package:f5xc_tool/model/user_model.dart';
import 'package:f5xc_tool/model/http_lb_version_model.dart';
import 'package:f5xc_tool/screen/dashboard/http_load_balancer/widgets/http_changes_dialog.dart';
import 'package:f5xc_tool/screen/dashboard/http_load_balancer/widgets/replace_version_dialog.dart';
import 'package:f5xc_tool/screen/dashboard/http_load_balancer/widgets/revision_dialog.dart';
import 'package:f5xc_tool/widgets/list_tile_shimmer.dart';
import 'package:f5xc_tool/widgets/user_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/languages/json.dart';

class MyList extends StatefulWidget {
  const MyList(
      {super.key,
      required this.modelList,
      required this.policyType,
      required this.user});

  final PolicyType policyType;
  final ListHttpLBVersionModel modelList;
  final UserResponse user;

  @override
  State<MyList> createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  late FlutterSecureStorage storage;
  late String auth = '';

  @override
  Widget build(BuildContext context) {
    UserModel userModel = widget.user.model ?? UserModel();
    // getData();
    if (widget.modelList.responseCode > 200) {
      return Text('Error ${widget.modelList.responseCode}');
    } else if (widget.modelList.versionData == null) {
      return ListTileShimmer();
    } else {
      List<HttpLBVersionModel> model =
          widget.modelList.versionData ?? [HttpLBVersionModel()];
      return ListView.builder(
          itemCount: widget.modelList.versionData!.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Card(
              child: ExpansionTile(
                  leading: AdjustedCircleAvatar(
                      backgroundColor: model[index].environment == "staging"
                          ? Colors.blueGrey
                          : Colors.blue,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.shield),
                          Text(
                            "${model[index].currentVersion}",
                            style: TextStyle(color: Colors.black),
                          )
                        ],
                      )),
                  title: Text('${model[index].appName}'.toUpperCase()),
                  subtitle:
                      Text('Active version: ${model[index].currentVersion}'),
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.subdirectory_arrow_right_rounded,
                        color: Colors.black.withAlpha(100),
                      ),
                      title: FutureBuilder(
                          future: _buildChildren(model[index]),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.done:
                                ListRevisionModelHTTPLB data = snapshot.data ??
                                    ListRevisionModelHTTPLB(responseCode: 400);
                                return _buildRevisionList(
                                    data, model[index], userModel);
                              default:
                                return Container();
                            }
                          }),
                    )
                  ]),
            );
          });
    }
  }

  Widget _buildRevisionList(
      ListRevisionModelHTTPLB data, HttpLBVersionModel model, UserModel user) {
    List<RevisionModelHTTPLB> modelList = data.listRevisionModel ?? [];
    return ListView.builder(
        itemCount: modelList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (data.responseCode > 200) {
            return ListTile(
              title: Text('Error was found in building list.'),
            );
          }
          bool active = modelList[index].version == model.currentVersion;
          return ExpansionTile(
            childrenPadding: EdgeInsets.only(left: 24),
            leading: Tooltip(
              message: active ? "Active Policy" : "Inactive Policy",
              child: CircleAvatar(
                backgroundColor: active ? Colors.green : Colors.blueGrey,
                child: active
                    ? Icon(
                        Icons.policy_rounded,
                        color: Colors.white,
                      )
                    : Icon(Icons.policy_outlined, color: Colors.white),
              ),
            ),
            title: Text(
                '${modelList[index].appName!.toUpperCase()} Version ${modelList[index].version}'),
            subtitle: Text(
                'Date modified: ${RequestHelper().dateTimeFromEpoch((modelList[index].timestamp!), 'Asia/Singapore')} GMT +8'),
            children: [
              ListTile(
                subtitle: Text(modelList[index].generatedBy!.toUpperCase()),
                title: Text('Generated by'),
              ),
              ListTile(
                  title: Text(
                      'Changes from Version ${modelList[index].previousVersion ?? (modelList[index].version ?? 1) - 1}'),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog.adaptive(
                            content: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.height * 0.8,
                              child: SingleChildScrollView(
                                child: HTTPChangesDialog(
                                    revision: modelList[index],
                                    environment:
                                        model.environment ?? "production"),
                              ),
                            ),
                            actions: [
                              TextButton(
                                child: Text('Close'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          );
                        });
                  }),
              ListTile(
                title: Text('Load Balancer Configuration'),
                trailing: Icon(Icons.navigate_next),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return RevisionDialog(
                            title: Text('Load Balancer Configuration'),
                            jsonData: modelList[index].lbConfig ?? {});
                      });
                },
              ),
              ListTile(
                title: Text('Origin Pool Configuration'),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return RevisionDialog(
                            title: Text('Origin Pool Configuration'),
                            jsonData: modelList[index].originConfig ?? []);
                      });
                },
                trailing: Icon(Icons.navigate_next),
              ),
              ListTile(
                trailing: Icon(Icons.navigate_next),
                title: Text('Application Firewall Configuration'),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return RevisionDialog(
                            title: Text('Application Firewall Configuration'),
                            jsonData: modelList[index].wafConfig ?? {});
                      });
                },
              ),
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      label: Text('Compare...'),
                      icon: Icon(Icons.account_tree),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Visibility(
                        visible: model.environment == "staging",
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          label: Text('Promote'),
                          icon: Icon(Icons.upload_file),
                        )),
                    SizedBox(
                      width: 8,
                    ),
                    Visibility(
                        visible: !active && user.role == "admin",
                        child: ElevatedButton.icon(
                            onPressed: replaceVersion(modelList[index], model),
                            label: Text('Replace Version'),
                            icon: Icon(Icons.history_edu)))
                  ],
                ),
              )
            ],
          );
        });
  }

  Future<ListRevisionModelHTTPLB> _buildChildren(
      HttpLBVersionModel model) async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    PolicyType type = model.environment == "staging"
        ? PolicyType.staging
        : PolicyType.production;
    // return await SqlQueryHelper()
    //     .getAllRevisions(bearer, model.appName ?? "", type);

    return SqlQueryHelper()
        .getAllHttpRevisions(bearer, model.appName ?? "", type);
  }

  Function() replaceVersion(
      RevisionModelHTTPLB data, HttpLBVersionModel model) {
    return () {
      showDialog(
          context: context,
          builder: (context) {
            return ReplaceVersionDialog(
                data: data, model: model, policyType: widget.policyType);
          });
    };
  }
}
