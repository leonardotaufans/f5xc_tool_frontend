import 'dart:async';

import 'package:f5xc_tool/middleware/request_helper.dart';
import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/event_log_model.dart';
import 'package:f5xc_tool/widgets/data_table_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EventLogDashboard extends StatefulWidget {
  const EventLogDashboard({super.key});

  @override
  State<EventLogDashboard> createState() => EventLogDashboardState();
}

class EventLogDashboardState extends State<EventLogDashboard> {
  ListEventLogModel model = ListEventLogModel(responseCode: 100);
  late StreamController<ListEventLogModel> _streamController;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<ListEventLogModel>();
    getEventLogAsStream();
  }

  getEventLogAsStream() async {
    print('refresh');
    ListEventLogModel event = await getEventLogs();
    _streamController.sink.add(event);
  }

  void callback() {
    print('callback');
    getEventLogs().then((val){
      setState(() {
        _streamController.sink.add(val);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: 30,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Event Logs',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w100,
                    color: Theme.of(context).primaryColor),
              ),
              SizedBox(
                width: 8,
              ),
              OutlinedButton.icon(
                  onPressed: () {
                    getEventLogAsStream();
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Refresh')),
            ],
          ),
        ),
        SizedBox(height: 8),
        StreamBuilder(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return DataTableLoading(); //todo:
                case ConnectionState.none:
                  return Text('None');
                default:
                  List<EventLogModel> models = snapshot.data?.eventLogs ?? [];
                  return DataTable(
                      sortColumnIndex: 1,
                      sortAscending: false,
                      columns: [
                        DataColumn(label: Expanded(child: Text('Event Type'))),
                        DataColumn(label: Expanded(child: Text('Timestamp'))),
                        DataColumn(label: Expanded(child: Text('Environment'))),
                        DataColumn(
                            label: Expanded(
                                child: Text(
                              'Previous\nVersion',
                              textAlign: TextAlign.center,
                            )),
                            numeric: true),
                        DataColumn(
                            label: Text('Target\nVersion',
                                textAlign: TextAlign.center),
                            numeric: true),
                        DataColumn(label: Text('Description'))
                      ],
                      showCheckboxColumn: true,
                      onSelectAll: (_) {},
                      rows: models
                          .map((val) => DataRow(cells: [
                                DataCell(Text('${val.eventType}')),
                                DataCell(Text(
                                    '${RequestHelper().dateTimeFromEpoch(val.timestamp ?? 1, 'Asia/Singapore')} GMT +8')),
                                DataCell(Text('${val.environment}')),
                                DataCell(Text('${val.previousVersion}')),
                                DataCell(Text('${val.targetVersion}')),
                                DataCell(Text('${val.description}')),
                              ]))
                          .toList());
              }
            }),
        // Text('Future'),
        // FutureBuilder(
        //     future: futureModel,
        //     initialData: model,
        //     builder: (context, snapshot) {
        //       switch (snapshot.connectionState) {
        //         case ConnectionState.done:
        //           List<EventLogModel> models = snapshot.data?.eventLogs ?? [];
        //           return DataTable(
        //               sortColumnIndex: 1,
        //               sortAscending: false,
        //               columns: [
        //                 DataColumn(label: Expanded(child: Text('Event Type'))),
        //                 DataColumn(label: Expanded(child: Text('Timestamp'))),
        //                 DataColumn(label: Expanded(child: Text('Environment'))),
        //                 DataColumn(
        //                     label: Expanded(
        //                         child: Text(
        //                       'Previous\nVersion',
        //                       textAlign: TextAlign.center,
        //                     )),
        //                     numeric: true),
        //                 DataColumn(
        //                     label: Text('Target\nVersion',
        //                         textAlign: TextAlign.center),
        //                     numeric: true),
        //                 DataColumn(label: Text('Description'))
        //               ],
        //               showCheckboxColumn: true,
        //               onSelectAll: (_) {},
        //               rows: models
        //                   .map((val) => DataRow(cells: [
        //                         DataCell(Text('${val.eventType}')),
        //                         DataCell(Text(
        //                             '${RequestHelper().dateTimeFromEpoch(val.timestamp ?? 1, 'Asia/Singapore')} GMT +8')),
        //                         DataCell(Text('${val.environment}')),
        //                         DataCell(Text('${val.previousVersion}')),
        //                         DataCell(Text('${val.targetVersion}')),
        //                         DataCell(Text('${val.description}')),
        //                       ]))
        //                   .toList());
        //         case ConnectionState.waiting:
        //           return Placeholder(); //todo:
        //         case ConnectionState.none:
        //           return Text('None');
        //         default:
        //           return Text('Default');
        //       }
        //     }),
      ],
    );
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  Future<ListEventLogModel> getEventLogs() async {
    String bearer = await FlutterSecureStorage().read(key: 'auth') ?? "";
    ListEventLogModel model = await SqlQueryHelper().getEventLogs(bearer);
    return model;
  }
}
