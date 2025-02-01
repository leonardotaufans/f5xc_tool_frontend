import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/user_model.dart';
import 'package:f5xc_tool/model/version_model.dart';
import 'package:f5xc_tool/screen/dashboard/load_balancer/my_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../middleware/config.dart';

class PolicyDashboard extends StatefulWidget {
  final String authKey = '';

  const PolicyDashboard({super.key, authKey});

  @override
  State<PolicyDashboard> createState() => PolicyDashboardState();
}

class PolicyDashboardState extends State<PolicyDashboard> {
  late ListVersionModel _stagingModel = ListVersionModel(responseCode: 100);
  late ListVersionModel _productionModel = ListVersionModel(responseCode: 100);
  late UserResponse _user = UserResponse(statusCode: 100);
  late String timezone = 'Asia/Singapore';

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
                    IconButton.filledTonal(
                        onPressed: () {
                          getStagingData().then((val) {
                            setState(() {
                              _stagingModel = val;
                            });
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh Table'),
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
                    IconButton.filledTonal(
                        onPressed: () {
                          getProductionData().then((val) {
                            setState(() {
                              _productionModel = val;
                            });
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh Table'),
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

  Widget myBottomSheet(BuildContext context, String appId) {
    return Container();
  }

  @override
  void initState() {
    super.initState();
    getStagingData().then((val) => setState(() => _stagingModel = val));
    getProductionData().then((val) => setState(() => _productionModel = val));
    getMyself().then((val) => setState(() => _user = val));
  }

  void callback() {
    setState(() {
      getStagingData().then((val) => setState(() => _stagingModel = val));
      getProductionData().then((val) => setState(() => _productionModel = val));
    });
  }

  Future<ListVersionModel> getStagingData() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    return SqlQueryHelper().getApps(PolicyType.staging, bearer);
  }

  Future<ListVersionModel> getProductionData() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    return SqlQueryHelper().getApps(PolicyType.production, bearer);
  }

  Future<UserResponse> getMyself() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    return SqlQueryHelper().getMyself(bearer);
  }
}
