import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/cdn_lb_model.dart';
import 'package:f5xc_tool/model/http_lb_version_model.dart';
import 'package:f5xc_tool/model/tcp_lb_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PolicyDiffFrag extends StatefulWidget {
  const PolicyDiffFrag({super.key});

  @override
  State<PolicyDiffFrag> createState() => _PolicyDiffFragState();
}

class _PolicyDiffFragState extends State<PolicyDiffFrag> {
  Set<String> _selectedLBType = {'HTTP'};
  Set<String> _selectedEnvironment = {'production'};
  String pathLb = "http_lb";
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

  @override
  Widget build(BuildContext context) {
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
                    pathLb = "http_lb";
                    break;
                  case "TCP":
                    pathLb = "tcp_lb";
                    break;
                  case "CDN":
                    pathLb = "cdn_lb";
                }
              });
            },
          ),
          SizedBox(
            height: 8,
          ),
          Text(
            'Environment',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SegmentedButton<String>(
            style: ButtonStyle(visualDensity: VisualDensity.compact),
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
            selected: _selectedEnvironment,
            onSelectionChanged: (object) {
              setState(() {
                _selectedEnvironment = object;
              });
            },
          ),
          Text('Virtual Server Name'),
          DropdownMenu(
            dropdownMenuEntries: buildDropdownAppName(),
            onSelected: ((selected) {
              setState(() {
                oldAppName = selected ?? "";
              });
            }),
          ),
          Text('Version'),
          DropdownMenu(
            dropdownMenuEntries: buildDropdownAppName(),
            onSelected: ((selected) {
              setState(() {
                oldAppName = selected ?? "";
              });
            }),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuEntry<String>> buildDropdownAppName() {
    List<DropdownMenuEntry<String>> widget = [];
    listVersionModel(_selectedLBType.first).then((val) {
      for (var each in val) {
        widget.add(
            DropdownMenuEntry<String>(value: each, label: each.toUpperCase()));
      }
    });
    return widget;
  }

  List<DropdownMenuEntry<String>> buildDropdownVersion() {
    List<DropdownMenuEntry<String>> widget = [];

    return widget;
  }

  Future<List<String>> listVersionModel(String lbType) async {
    String bearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    PolicyType type = PolicyType.production;
    switch (_selectedEnvironment.first) {
      case "production":
        type = PolicyType.production;
        break;
      case "staging":
        type = PolicyType.staging;
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
}
