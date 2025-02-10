import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/cdn_lb_model.dart';
import 'package:f5xc_tool/model/http_lb_revision_model.dart';
import 'package:f5xc_tool/model/http_lb_version_model.dart';
import 'package:f5xc_tool/model/tcp_lb_model.dart';
import 'package:f5xc_tool/screen/diff/widgets/compare_version.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PolicyDiffFrag extends StatefulWidget {
  const PolicyDiffFrag({super.key});

  @override
  State<PolicyDiffFrag> createState() => _PolicyDiffFragState();
}

class _PolicyDiffFragState extends State<PolicyDiffFrag> {
  Set<String> _selectedLBType = {'null'};
  Set<String> _selectedEnvironmentOld = {'null'};
  Set<String> _selectedEnvironmentNew = {'null'};
  String pathLb = "http-lb";
  String oldAppName = "";
  int oldVer = 0;
  String newAppName = "";
  int newVer = 0;
  ListHttpLBVersionModel httpVersionModel =
      ListHttpLBVersionModel(responseCode: 100);
  ListTcpLBVersionModel tcpVersionModel =
      ListTcpLBVersionModel(responseCode: 100);
  ListCDNLBVersionModel cdnVersionModel =
      ListCDNLBVersionModel(responseCode: 100);
  List<String> oldAppList = [];
  List<int> oldVerList = [];
  List<String> newAppList = [];
  List<int> newVerList = [];

  @override
  Widget build(BuildContext context) {
    Future<List<String>> futureOldAppName =
        listApp(_selectedLBType, _selectedEnvironmentOld);
    Future<List<String>> futureNewAppName =
        listApp(_selectedLBType, _selectedEnvironmentNew);
    Future<List<int>> futureOldVer =
        listVersion(_selectedLBType, oldAppName, _selectedEnvironmentOld);
    Future<List<int>> futureNewVer =
        listVersion(_selectedLBType, newAppName, _selectedEnvironmentNew);

    return Padding(
      padding: EdgeInsets.all(8),
      child: ListView(
        children: [
          Text(
            'Load Balancer Type',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SegmentedButton<String>(
            style: ButtonStyle(visualDensity: VisualDensity.compact),
            segments: <ButtonSegment<String>>[
              ButtonSegment(
                  value: "HTTP",
                  icon: Icon(Icons.http),
                  label: Text("HTTP LB")),
              ButtonSegment(
                  value: "TCP",
                  icon: Icon(Icons.account_tree),
                  label: Text("TCP LB")),
              ButtonSegment(
                  value: "CDN",
                  icon: Icon(Icons.cloud_outlined),
                  label: Text("CDN LB"))
            ],
            selected: _selectedLBType,
            onSelectionChanged: (object) {
              setState(() {
                _selectedLBType = object;
                switch (object.first) {
                  case "HTTP":
                    pathLb = "http-lb";
                    break;
                  case "TCP":
                    pathLb = "tcp-lb";
                    break;
                  case "CDN":
                    pathLb = "cdn-lb";
                }
              });
            },
          ),
          SizedBox(
            height: 8,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width * 0.85,
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: ListView(
                        children: [
                          Center(
                            child: Text(
                              'Old Revision',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          SegmentedButton<String>(
                            style: ButtonStyle(
                                visualDensity: VisualDensity.compact),
                            segments: <ButtonSegment<String>>[
                              ButtonSegment(
                                  value: "staging",
                                  icon: Icon(Icons.shield_outlined),
                                  label: Text("Staging")),
                              ButtonSegment(
                                  value: "production",
                                  icon: Icon(Icons.shield_rounded),
                                  label: Text("Production")),
                            ],
                            selected: _selectedEnvironmentOld,
                            onSelectionChanged: (object) {
                              _selectedEnvironmentOld = object;
                              setState(() {
                                _selectedEnvironmentOld = object;
                              });
                              // listApp(_selectedLBType, _selectedEnvironmentOld)
                              //     .then((val) {
                              //   setState(() {
                              //     oldAppList = val;
                              //   });
                              // });
                            },
                          ),
                          Text('Virtual Server Name'),
                          FutureBuilder(
                              future: futureOldAppName,
                              // future: listApp(
                              //     _selectedLBType, _selectedEnvironmentOld),
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.done:
                                    List<String> appList = snapshot.data ?? [];
                                    return DropdownMenu<String>(
                                      dropdownMenuEntries: appList
                                          .map((list) => DropdownMenuEntry(
                                              value: list,
                                              label: list.toUpperCase()))
                                          .toList(),
                                      onSelected: (sel) {
                                        setState(() {
                                          oldAppName = sel ?? "";
                                        });
                                      },
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      initialSelection: oldAppName,
                                    );
                                  case ConnectionState.waiting:
                                    return DropdownMenu(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        dropdownMenuEntries: [
                                          DropdownMenuEntry(
                                              value: oldAppName,
                                              label: oldAppName.toUpperCase(),
                                              enabled: false)
                                        ]);
                                  case ConnectionState.none:
                                    return DropdownMenu(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        dropdownMenuEntries: [
                                          DropdownMenuEntry(
                                              value: oldAppName,
                                              label: oldAppName.toUpperCase(),
                                              enabled: false)
                                        ]);
                                  default:
                                    return DropdownMenu(dropdownMenuEntries: [
                                      DropdownMenuEntry(
                                          value: 'null',
                                          label: 'Select...',
                                          enabled: false)
                                    ]);
                                }
                              }),
                          Text('Version'),
                          FutureBuilder(
                            future: futureOldVer,
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.done:
                                  List<int> listVer = snapshot.data ?? [];
                                  return DropdownMenu<int>(
                                    dropdownMenuEntries: listVer
                                        .map((v) => DropdownMenuEntry(
                                            value: v, label: v.toString()))
                                        .toList(),
                                    onSelected: (sel) {
                                      setState(() {
                                        oldVer = sel ?? 0;
                                      });
                                    },
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    initialSelection: oldVer,
                                  );
                                case ConnectionState.waiting:
                                  return DropdownMenu(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      dropdownMenuEntries: [
                                        DropdownMenuEntry(
                                            value: oldVer, label: '$oldVer')
                                      ]);
                                case ConnectionState.none:
                                  return DropdownMenu(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      dropdownMenuEntries: [
                                        DropdownMenuEntry(
                                            value: oldVer,
                                            label: 'App name unselected')
                                      ]);
                                default:
                                  return DropdownMenu(dropdownMenuEntries: [
                                    DropdownMenuEntry(
                                        value: 'null',
                                        label: 'App name unselected')
                                  ]);
                              }
                            },
                          )
                        ],
                      ),
                    )),
                SizedBox(width: 16),
                Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: ListView(
                        children: [
                          Center(
                            child: Text(
                              'New Revision',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          SegmentedButton<String>(
                            style: ButtonStyle(
                                visualDensity: VisualDensity.compact),
                            segments: <ButtonSegment<String>>[
                              ButtonSegment(
                                  value: "staging",
                                  icon: Icon(Icons.shield_outlined),
                                  label: Text("Staging")),
                              ButtonSegment(
                                  value: "production",
                                  icon: Icon(Icons.shield_rounded),
                                  label: Text("Production")),
                            ],
                            selected: _selectedEnvironmentNew,
                            onSelectionChanged: (object) {
                              setState(() {
                                _selectedEnvironmentNew = object;
                              });
                              listApp(_selectedLBType, _selectedEnvironmentNew)
                                  .then((val) {
                                setState(() {
                                  newAppList = val;
                                });
                              });
                            },
                          ),
                          Text('Virtual Server Name'),
                          FutureBuilder(
                              future: futureNewAppName,
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.done:
                                    List<String> appList = snapshot.data ?? [];
                                    return DropdownMenu<String>(
                                      dropdownMenuEntries: appList
                                          .map((list) => DropdownMenuEntry(
                                              value: list,
                                              label: list.toUpperCase()))
                                          .toList(),
                                      onSelected: (value) {
                                        setState(() {
                                          newAppName = value ?? "";
                                        });
                                      },
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      initialSelection: newAppName,
                                    );
                                  case ConnectionState.waiting:
                                    return DropdownMenu(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        dropdownMenuEntries: [
                                          DropdownMenuEntry(
                                              value: newAppName,
                                              label: newAppName.toUpperCase(),
                                              enabled: false)
                                        ]);
                                  case ConnectionState.none:
                                    return DropdownMenu(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        dropdownMenuEntries: [
                                          DropdownMenuEntry(
                                              value: newAppName,
                                              label: newAppName.toUpperCase(),
                                              enabled: false)
                                        ]);
                                  default:
                                    return DropdownMenu(dropdownMenuEntries: [
                                      DropdownMenuEntry(
                                          value: 'null',
                                          label: 'Select...',
                                          enabled: false)
                                    ]);
                                }
                              }),
                          Text('Version'),
                          FutureBuilder(
                            future: futureNewVer,
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.done:
                                  List<int> listVer = snapshot.data ?? [];
                                  return DropdownMenu<int>(
                                    dropdownMenuEntries: listVer
                                        .map((v) => DropdownMenuEntry(
                                            value: v, label: v.toString()))
                                        .toList(),
                                    onSelected: (sel) {
                                      setState(() {
                                        newVer = sel ?? 0;
                                      });
                                    },
                                    initialSelection: newVer,
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                  );
                                case ConnectionState.waiting:
                                  return DropdownMenu(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      dropdownMenuEntries: [
                                        DropdownMenuEntry(
                                            value: newVer, label: '$newVer')
                                      ]);
                                case ConnectionState.none:
                                  return DropdownMenu(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      dropdownMenuEntries: [
                                        DropdownMenuEntry(
                                            value: newVer,
                                            label: 'App name unselected')
                                      ]);
                                default:
                                  return DropdownMenu(dropdownMenuEntries: [
                                    DropdownMenuEntry(
                                        value: 'null',
                                        label: 'App name unselected')
                                  ]);
                              }
                            },
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          ElevatedButton(
              onPressed: () {
                compareVersion(
                        _selectedLBType,
                        oldAppName,
                        oldVer,
                        _selectedEnvironmentOld.first,
                        newAppName,
                        newVer,
                        _selectedEnvironmentNew.first)
                    .then((val) {
                  if (context.mounted) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                child: CompareVersionWidget(jsonData: val)),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Close'))
                            ],
                          );
                        });
                  }
                });
              },
              child: Text('Compare')),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Future<List<String>> listApp(
      Set<String> setLbType, Set<String> selEnv) async {
    String lbType = setLbType.first;
    String bearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    PolicyType type;
    switch (selEnv.first) {
      case "production":
        type = PolicyType.production;
      case "staging":
        type = PolicyType.staging;
      default:
        type = PolicyType.production;
    }
    List<String> appsList = [];
    switch (lbType) {
      case "HTTP":
        ListHttpLBVersionModel httpList =
            await SqlQueryHelper().getHttpVersion(type, bearer);
        for (var each in httpList.versionData ??
            [HttpLBVersionModel(appName: "Select apps:")]) {
          appsList.add(each.appName ?? "");
        }
        return appsList;
      case "TCP":
        ListTcpLBVersionModel tcpList =
            await SqlQueryHelper().getTcpVersion(type, bearer);
        for (var each in tcpList.modelList ??
            [TcpLBVersionModel(appName: "Select apps:")]) {
          appsList.add(each.appName ?? "");
        }
        return appsList;
      case "CDN":
        ListCDNLBVersionModel cdnList =
            await SqlQueryHelper().getCDNVersion(type, bearer);
        for (var each in cdnList.modelList ??
            [CDNLBVersionModel(appName: "Select apps:")]) {
          appsList.add(each.appName ?? "");
        }
        return appsList;
      default:
        return appsList;
    }
  }

  Future<List<int>> listVersion(
      Set<String> setLbType, String lbName, Set<String> environment) async {
    String lbType = setLbType.first;
    String bearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    PolicyType type;
    if (lbName.isEmpty) {
      return [0];
    }
    switch (environment.first) {
      case "production":
        type = PolicyType.production;
        break;
      case "staging":
        type = PolicyType.staging;
        break;
      default:
        type = PolicyType.production;
    }
    List<int> verList = [];
    switch (lbType) {
      case "HTTP":
        ListRevisionModelHTTPLB listLb =
            await SqlQueryHelper().getAllHttpRevisions(bearer, lbName, type);
        for (var each in listLb.listRevisionModel ?? [RevisionModelHTTPLB()]) {
          verList.add(each.version ?? 0);
        }
        break;
      case "TCP":
        ListTcpLBRevisionModel listTcp =
            await SqlQueryHelper().getAllTcpRevisions(bearer, lbName, type);
        for (var each in listTcp.modelList ?? [TcpLBRevisionModel()]) {
          verList.add(each.version ?? 0);
        }
        break;
      case "CDN":
        ListCDNLBRevisionModel listCDN =
            await SqlQueryHelper().getAllCDNRevisions(bearer, lbName, type);
        for (var each in listCDN.modelList ?? [CDNLBRevisionModel()]) {
          verList.add(each.version ?? 0);
        }
        break;
    }
    return verList;
  }

  Future<String> compareVersion(
      Set<String> setLbType,
      String oldName,
      int oldVer,
      String oldType,
      String newName,
      int newVer,
      String newType) async {
    String bearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    String diffResult = await SqlQueryHelper().comparePolicy(
        bearer, pathLb, oldName, oldVer, oldType, newAppName, newVer, newType);

    return diffResult;
  }
}
