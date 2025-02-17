import 'dart:async';

import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/request_helper.dart';
import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/cdn_lb_model.dart';
import 'package:f5xc_tool/model/user_model.dart';
import 'package:f5xc_tool/screen/dashboard/cdn_load_balancer/widgets/cdn_changes_dialog.dart';
import 'package:f5xc_tool/screen/dashboard/http_load_balancer/widgets/revision_dialog.dart';
import 'package:f5xc_tool/widgets/alert_tbd.dart';
import 'package:f5xc_tool/widgets/list_tile_shimmer.dart';
import 'package:f5xc_tool/widgets/user_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:after_layout/after_layout.dart';
import 'replace_cdn_version_dialog.dart';

class CDNList extends StatefulWidget {
  const CDNList(
      {super.key,
      required this.modelList,
      required this.policyType,
      required this.user});

  final PolicyType policyType;
  final ListCDNLBVersionModel modelList;
  final UserResponse user;

  @override
  State<CDNList> createState() => _TcpListState();
}

class _TcpListState extends State<CDNList> with AfterLayoutMixin<CDNList> {
  late FlutterSecureStorage storage;
  late String auth = '';

  @override
  void afterFirstLayout(BuildContext context) {
    if (widget.modelList.responseCode > 200) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: Text('Login'),
                )
              ],
              content: Text("You need to log back in to continue."),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.modelList.responseCode > 200) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: Text('Login'),
                  )
                ],
                content: Text("You need to log back in to continue."),
              );
            });
      }
    });
    UserModel userModel = widget.user.model ?? UserModel();
    // getData();
    if (widget.modelList.responseCode > 200) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: Text('Login'),
                )
              ],
              content: Text("You need to log back in to continue."),
            );
          });
      return Text('Error ${widget.modelList.responseCode}');
    } else if (widget.modelList.modelList == null) {
      return ListTileShimmer();
    } else {
      List<CDNLBVersionModel> model =
          widget.modelList.modelList ?? [CDNLBVersionModel()];
      return ListView.builder(
          itemCount: widget.modelList.modelList!.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Card(
              child: ExpansionTile(
                  shape: Border(),
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
                      title: FutureBuilder(
                          future: _buildChildren(model[index]),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.done:
                                ListCDNLBRevisionModel data = snapshot.data ??
                                    ListCDNLBRevisionModel(responseCode: 400);
                                return _buildRevisionList(
                                    data, model[index], userModel);
                              case ConnectionState.waiting:
                                return ListView(
                                  shrinkWrap: true,
                                  children: [
                                    ListTileShimmer(),
                                    ListTileShimmer(),
                                    ListTileShimmer(),
                                    ListTileShimmer(),
                                  ],
                                );
                              default:
                                return ListView(
                                  shrinkWrap: true,
                                  children: [
                                    ListTileShimmer(),
                                    ListTileShimmer(),
                                    ListTileShimmer(),
                                    ListTileShimmer(),
                                  ],
                                );
                            }
                          }),
                    )
                  ]),
            );
          });
    }
  }

  Widget _buildRevisionList(
      ListCDNLBRevisionModel data, CDNLBVersionModel model, UserModel user) {
    List<CDNLBRevisionModel> modelList = data.modelList ?? [];
    return ListView.builder(
        itemCount: modelList.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (data.responseCode > 200) {
            return ListTile(
              title: Text('Error was found in building list.'),
            );
          }
          if (modelList.isEmpty) {
            return ListTileShimmer();
          }
          bool active = modelList[index].version == model.currentVersion;
          return ExpansionTile(
            shape: Border(left: BorderSide(color: Colors.black12)),
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
                                child: CDNChangesDialog(
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
                  title: Text('Remarks'),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Remarks'),
                            content: Text('${modelList[index].remarks}'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Close'),
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
                    SizedBox(
                      width: 8,
                    ),
                    Visibility(
                        visible: model.environment == "staging",
                        child: ElevatedButton.icon(
                          onPressed: () => showDialog(
                              context: context,
                              builder: (context) => AlertTbd()),
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

  Future<ListCDNLBRevisionModel> _buildChildren(CDNLBVersionModel model) async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    PolicyType type = model.environment == "staging"
        ? PolicyType.staging
        : PolicyType.production;
    // return await SqlQueryHelper()
    //     .getAllRevisions(bearer, model.appName ?? "", type);

    return await SqlQueryHelper()
        .getAllCDNRevisions(bearer, model.appName ?? "", type);
  }

  Function() replaceVersion(CDNLBRevisionModel data, CDNLBVersionModel model) {
    return () {
      showDialog(
          context: context,
          builder: (context) {
            return ReplaceCDNVersionDialog(
                data: data, model: model, policyType: widget.policyType);
          });
    };
  }
}
