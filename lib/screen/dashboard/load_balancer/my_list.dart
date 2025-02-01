import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/request_helper.dart';
import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/revision_model.dart';
import 'package:f5xc_tool/model/user_model.dart';
import 'package:f5xc_tool/model/version_model.dart';
import 'package:f5xc_tool/screen/dashboard/load_balancer/replace_version_dialog.dart';
import 'package:f5xc_tool/screen/dashboard/load_balancer/revision_dialog.dart';
import 'package:f5xc_tool/widgets/user_expansion_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyList extends StatefulWidget {
  const MyList({super.key,
    required this.modelList,
    required this.policyType,
    required this.user});

  final PolicyType policyType;
  final ListVersionModel modelList;
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
      return Text('Version Data is empty');
    } else {
      List<VersionModel> model =
          widget.modelList.versionData ?? [VersionModel()];
      return ListView.builder(
          itemCount: widget.modelList.versionData!.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Card(
              child: ExpansionTile(
                // title: ListTile(
                //   style: ListTileStyle.drawer,
                //   leading: IconButton.filledTonal(
                //       tooltip: model[index].environment?.toUpperCase() ??
                //           "Staging",
                //       onPressed: null,
                //       icon: model[index].environment == "staging"
                //           ? Icon(Icons.shield_outlined)
                //           : Icon(Icons.shield_rounded)),
                //   title: Text('${model[index].appName}'),
                //   subtitle: Text(
                //       'Version ${model[index].currentVersion} is active.'),
                // ),
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
                  title: Text('${model[index].appName}'),
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
                                ListRevisionModel data = snapshot.data ??
                                    ListRevisionModel(responseCode: 400);
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

  Widget _buildRevisionList(ListRevisionModel data, VersionModel model,
      UserModel user) {
    List<RevisionModel> modelList = data.listRevisionModel ?? [];
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
                '${modelList[index].appName} Version ${modelList[index]
                    .version}'),
            subtitle: Text(
                'Date modified: ${RequestHelper().dateTimeFromEpoch(
                    (modelList[index].timestamp!), 'Asia/Singapore')} GMT +8'),
            children: [
              ListTile(
                subtitle: Text(modelList[index].generatedBy!.toUpperCase()),
                title: Text('Generated by'),
              ),
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

  Future<ListRevisionModel> _buildChildren(VersionModel model) async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    PolicyType type = model.environment == "staging"
        ? PolicyType.staging
        : PolicyType.production;
    // return await SqlQueryHelper()
    //     .getAllRevisions(bearer, model.appName ?? "", type);

    return SqlQueryHelper().getAllRevisions(bearer, model.appName ?? "", type);
  }

  Function() replaceVersion(RevisionModel data, VersionModel model) {
    return () {
      showDialog(
          context: context,
          builder: (context) {
            return ReplaceVersionDialog(data: data, model: model, policyType: widget.policyType);
            // return AlertDialog(
            //   title: Text('Replace Version'),
            //   content: Text(
            //       'Replace version ${data.appName}:${widget
            //           .policyType} version ${model.currentVersion} with ${data
            //           .version}.\nAre you sure?'),
            //   actions: [
            //     TextButton(
            //       onPressed: () {
            //         showDialog(context: context,
            //             builder: (_) =>
            //                 ReplaceVersionDialog(data: data,
            //                     model: model,
            //                     policyType: widget.policyType));
            //       },
            //       child: Text('Yes'),
            //     ),
            //     TextButton(
            //       onPressed: () {
            //         Navigator.pop(context);
            //       },
            //       child: Text('No'),
            //     )
            //   ],
            // );
          });
    };
  }
}
