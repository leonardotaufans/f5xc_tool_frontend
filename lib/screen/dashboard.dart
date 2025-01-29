import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/auth_model.dart';
import 'package:f5xc_tool/model/revision_model.dart';
import 'package:f5xc_tool/screen/dashboard/my_nav_rail.dart';
import 'package:f5xc_tool/screen/dashboard/load_balancer/snapshot_dialog.dart';
import 'package:f5xc_tool/screen/policy_diff_frag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dashboard/event_log_frag.dart';
import 'dashboard/policy_frag.dart';
import 'dashboard/user_frag.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var _selectedIndex = 0;
  late FlutterSecureStorage _storage;
  late String _authKey = '';
  late AuthModel model;

  @override
  void initState() {
    super.initState();
    _storage = const FlutterSecureStorage();
  }

  Future<AuthResponse> verifyLogin() async {
    String storage = await _storage.read(key: 'auth') ?? "";
    _authKey = storage;
    AuthResponse authData = await SqlQueryHelper().verifyAuth(storage);
    return authData;
  }

  void indexCallback(int selectedIndex) {
    setState(() {
      _selectedIndex = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          MyNavRail(indexCallback: indexCallback),
          const VerticalDivider(),
          Expanded(child: switchPages(_selectedIndex))
        ],
      ),
      //todo: create FAB builder to follow the current page using indexCallback
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var snap = snapshot();
          if (context.mounted) {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return SnapshotDialog(
                    bearer: _authKey,
                  );
                });
          }
          snap.then((value) {
            if (context.mounted) {
              // PolicyDashboardState().callback();
              Navigator.pop(context);
            }
          });
        },
        label: Text('Snapshot Now'),
        icon: Icon(Icons.download_for_offline_outlined),
      ),
    );
  }

  Future<ListRevisionModel> snapshot() async {
    String authKey = await _storage.read(key: 'auth') ?? "";
    print('snapshot doko??? authKey: $authKey');
    return SqlQueryHelper().snapshotManual(authKey);
  }

  Widget switchPages(int index) {
    switch (index) {
      case 1:
        return const PolicyDiffFrag();
      case 2:
        return const UserDashboard();
      case 3:
        return const EventLogDashboard();

      default:
        return const PolicyDashboard();
    }
  }
}
