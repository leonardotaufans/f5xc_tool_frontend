import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/cdn_lb_model.dart';
import 'package:f5xc_tool/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../middleware/config.dart';
import 'widgets/cdn_list.dart';

class CDNDashboard extends StatefulWidget {
  final String authKey = '';

  const CDNDashboard({super.key, authKey});

  @override
  State<CDNDashboard> createState() => CDNDashboardState();
}

class CDNDashboardState extends State<CDNDashboard> {
  late ListCDNLBVersionModel _stagingModel =
      ListCDNLBVersionModel(responseCode: 100);
  late ListCDNLBVersionModel _productionModel =
      ListCDNLBVersionModel(responseCode: 100);
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
                    Tooltip(
                      message: 'Refresh Staging Table',
                      child: OutlinedButton.icon(
                          label: Text('Refresh'),
                          onPressed: () {
                            getStagingData().then((val) {
                              setState(() {
                                _stagingModel = val;
                              });
                            });
                          },
                          icon: const Icon(Icons.refresh)),
                    ),
                  ],
                ),
              ),
              CDNList(
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
                      message: 'Refresh Production Table',
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
              CDNList(
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

  Future<ListCDNLBVersionModel> getStagingData() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    return SqlQueryHelper().getCDNVersion(PolicyType.staging, bearer);
  }

  Future<ListCDNLBVersionModel> getProductionData() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    return SqlQueryHelper().getCDNVersion(PolicyType.production, bearer);
  }

  Future<UserResponse> getMyself() async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    String bearer = await storage.read(key: 'auth') ?? "";
    return SqlQueryHelper().getMyself(bearer);
  }
}
