import 'dart:async';

import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/user_model.dart';
import 'package:f5xc_tool/model/http_lb_version_model.dart';
import 'package:f5xc_tool/screen/dashboard/http_load_balancer/widgets/my_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../middleware/config.dart';

class HttpPolicyDashboard extends StatefulWidget {
  final String authKey = '';

  const HttpPolicyDashboard({super.key, authKey});

  @override
  State<HttpPolicyDashboard> createState() => HttpPolicyDashboardState();
}

class HttpPolicyDashboardState extends State<HttpPolicyDashboard> {
  late ListHttpLBVersionModel _stagingModel =
      ListHttpLBVersionModel(responseCode: 100);
  late ListHttpLBVersionModel _productionModel =
      ListHttpLBVersionModel(responseCode: 100);
  late UserResponse _user = UserResponse(statusCode: 100);
  late String timezone = 'Asia/Singapore';
  final SqlQueryHelper sqlQuery = SqlQueryHelper();
  @override
  void initState() {
    super.initState();
    getMyself().then((val) => setState(() => _user = val));
  }

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          flex: 4,
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined),
                    const SizedBox(
                      width: 16,
                    ),
                    Text('Staging',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(
                      width: 16,
                    ),
                    Tooltip(
                      message: 'Refresh Table',
                      child: OutlinedButton.icon(
                        onPressed: () {
                          getStagingData().then((val) {
                            setState(() {
                              _stagingModel = val;
                            });
                          });
                        },
                        label: Text('Refresh'),
                        icon: const Icon(Icons.refresh),
                      ),
                    )
                  ],
                ),
              ),
              MyList(
                modelList: _stagingModel,
                policyType: PolicyType.staging,
                user: _user,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.shield_rounded),
                    const SizedBox(
                      width: 16,
                    ),
                    Text('Production',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(
                      width: 16,
                    ),
                    Tooltip(
                      message: 'Refresh Table',
                      child: OutlinedButton.icon(
                          label: Text('Refresh'),
                          onPressed: () {
                            getProductionData().then((val) {
                              setState(() {
                                _productionModel = val;
                              });
                            });
                          },
                          icon: const Icon(Icons.refresh)),
                    ),
                  ],
                ),
              ),
              MyList(
                modelList: _productionModel,
                policyType: PolicyType.production,
                user: _user,
              )
              // tableBuilder(_productionModel
            ],
          ),
        ),
        Visibility(
          visible: false,
          child: Expanded(
            flex: 2,
            child: Container(
              color: Colors.green,
            ),
          ),
        )
      ],
    );
  }

  forceLogout() {
    if (context.mounted) {
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          content: Text('You need to log back in to continue.'),
        );
      });
    }
  }

  void callback() {
    setState(() {
      getStagingData().then((val) => setState(() => _stagingModel = val));
      getProductionData().then((val) => setState(() => _productionModel = val));
    });
  }

  Future<ListHttpLBVersionModel> getStagingData() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    var version =
        await SqlQueryHelper().getHttpVersion(PolicyType.staging, bearer);
    return version;
  }

  Future<ListHttpLBVersionModel> getProductionData() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    return SqlQueryHelper().getHttpVersion(PolicyType.production, bearer);
  }

  Future<UserResponse> getMyself() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    return SqlQueryHelper().getMyself(bearer);
  }
}
