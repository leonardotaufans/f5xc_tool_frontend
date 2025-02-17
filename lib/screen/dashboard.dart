// ignore_for_file: use_build_context_synchronously

import 'package:f5xc_tool/middleware/config.dart';
import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/auth_model.dart';
import 'package:f5xc_tool/model/snapshot_model.dart';
import 'package:f5xc_tool/screen/dashboard/cdn_load_balancer/cdn_dashboard.dart';
import 'package:f5xc_tool/screen/dashboard/tcp_load_balancer/tcp_dashboard.dart';
import 'package:f5xc_tool/screen/dashboard/widgets/my_nav_rail.dart';
import 'package:f5xc_tool/screen/dashboard/widgets/snapshot_dialog.dart';
import 'package:f5xc_tool/screen/dashboard/widgets/snapshot_remarks_dialog.dart';
import 'package:f5xc_tool/screen/diff/policy_diff_frag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'event_logs/event_log_frag.dart';
import 'dashboard/http_load_balancer/http_dashboard.dart';
import 'users/user_frag.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var _selectedIndex = 0;
  late FlutterSecureStorage _storage;
  late String _authKey = '';
  late AuthModel model = AuthModel(user: 'none', role: 'guest');
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _storage = const FlutterSecureStorage();
    verifyLogin().then((value) {
      if (value.auth != null) {
        setState(() {
          isAdmin = (value.auth!.role == UserRole.admin);
          model = value.auth ?? AuthModel(user: 'none', role: 'guest');
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
      appBar: AppBar(
        backgroundColor: isAdmin ? Colors.red.shade300 : Colors.blue.shade300,
        title: RichText(
            text: TextSpan(children: [
          TextSpan(
              text: '${model.user}@F5XC~${isAdmin ? "#" : "\$"} ',
              style: GoogleFonts.sourceCodePro()),
          TextSpan(text: PagesName.number[_selectedIndex].toUpperCase())
        ])),
        elevation: 1,
      ),
      body: Row(
        children: [
          MyNavRail(indexCallback: indexCallback),
          const VerticalDivider(),
          Expanded(
              child: Container(
                  color: Theme.of(context).canvasColor,
                  child: switchPages(_selectedIndex)))
        ],
      ),
      floatingActionButton: switchFab(_selectedIndex, isAdmin),
    );
  }

  Future<SnapshotResult> snapshot() async {
    String authKey = await _storage.read(key: 'auth') ?? "";
    return SqlQueryHelper().snapshotManual(authKey);
  }

  Widget switchPages(int index) {
    switch (index) {
      case Pages.policyDiff:
        return const PolicyDiffFrag();
      case Pages.users:
        return const UserDashboard();
      case Pages.eventLogs:
        return const EventLogDashboard();
      case Pages.cdnDashboard:
        return const CDNDashboard();
      case Pages.tcpDashboard:
        return const TcpPolicyDashboard();
      default:
        return const HttpPolicyDashboard();
    }
  }

  Widget switchFab(int index, bool isAdmin) {
    switch (index) {
      case Pages.policyDiff:
        // Policy Diff
        return SizedBox();
      case Pages.users:
        return SizedBox();
      case Pages.eventLogs:
        return SizedBox();
      // return FloatingActionButton(
      //     onPressed: refreshEventLogs, child: Icon(Icons.refresh));
      default:
        if (isAdmin) {
          return FloatingActionButton.extended(
              icon: Icon(Icons.sync),
              onPressed: fabSnapshot(),
              label: Text('Snapshot Now'));
        } else {
          return SizedBox();
        }
    }
  }

  Function() refreshEventLogs() {
    return () => EventLogDashboardState().callback;
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
          showDialog(
              context: context,
              builder: (context) {
                print("detail: ${value.detail}");
                return SnapshotRemarksDialog(
                    model: value.snapshot ??
                        SnapshotModel(
                            result: 'Error in capturing snapshot: Assert!'));
              });
        }
      });
    };
  }
}
