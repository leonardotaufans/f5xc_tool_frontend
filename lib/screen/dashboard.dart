import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/auth_model.dart';
import 'package:f5xc_tool/model/revision_model.dart';
import 'package:f5xc_tool/screen/dashboard/my_nav_rail.dart';
import 'package:f5xc_tool/screen/dashboard/load_balancer/snapshot_dialog.dart';
import 'package:f5xc_tool/screen/policy_diff_frag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dashboard/event_log_frag.dart';
import 'dashboard/load_balancer_frag.dart';
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
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _storage = const FlutterSecureStorage();
    verifyLogin().then((value) {
      if (value.auth != null) {
        setState(() {
          isAdmin = (value.auth!.role == UserRole.admin);
        });
      }
    });
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
      floatingActionButton: switchFab(_selectedIndex, isAdmin),
      // floatingActionButton: FloatingActionButton(
      //   selectedIndex: _selectedIndex,
      //   onPressed: fabSnapshot(),
      //   // onPressed: () async {
      //   //   var snap = snapshot();
      //   //   if (context.mounted) {
      //   //     showDialog(
      //   //         barrierDismissible: false,
      //   //         context: context,
      //   //         builder: (context) {
      //   //           return SnapshotDialog(
      //   //             bearer: _authKey,
      //   //           );
      //   //         });
      //   //   }
      //   //   snap.then((value) {
      //   //     if (context.mounted) {
      //   //       // PolicyDashboardState().callback();
      //   //       Navigator.pop(context);
      //   //     }
      //   //   });
      //   // },
      //   label: 'Snapshot Now',
      //   icon: Icon(Icons.download_for_offline_outlined),
      // ),
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

  Widget switchFab(int index, bool isAdmin) {
    switch (index) {
      case Pages.policyDiff:
        // Policy Diff
        return SizedBox();
      case Pages.users:
        if (isAdmin) {
          return FloatingActionButton.extended(
              icon: Icon(Icons.person_add),
              onPressed: newUserFunction(),
              label: Text('New User'));
        } else {
          return SizedBox();
        }
      case Pages.eventLogs:
        return FloatingActionButton(
            onPressed: refreshEventLogs(), child: Icon(Icons.refresh));
      default:
        if (isAdmin) {
          return FloatingActionButton.extended(
              icon: Icon(Icons.upload_rounded),
              onPressed: fabSnapshot(),
              label: Text('Snapshot Now'));
        } else {
          return SizedBox();
        }
    }
  }

  Function() refreshEventLogs() {
    return () {}; //todo: implement
  }

  Function() newUserFunction() {
    return () {}; //todo: implement
  }

  Function() fabSnapshot() {
    return () async {
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
    };
  }
}
