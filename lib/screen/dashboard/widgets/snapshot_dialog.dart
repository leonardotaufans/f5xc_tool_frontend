import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/snapshot_model.dart';
import 'package:flutter/material.dart';

class SnapshotDialog extends StatefulWidget {
  const SnapshotDialog({super.key, required this.bearer});

  final String bearer;

  @override
  State<SnapshotDialog> createState() => _SnapshotDialogState();
}

class _SnapshotDialogState extends State<SnapshotDialog> {
  late String val = '';

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final NavigatorState navigator = Navigator.of(context);
        await snapshot().then((value) {
          navigator.pop();
        });
        return true;
      },
      child: AlertDialog(
        title: Text('Snapshot'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.height * 0.1,
          child: Flex(
            direction: Axis.horizontal,
            children: [
              SizedBox(
                  width: 60, height: 60, child: CircularProgressIndicator()),
              SizedBox(width: 8,),
              Expanded(
                child: Text('Please wait. \nUpdating database...'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<SnapshotResult> snapshot() async {
    return await SqlQueryHelper().snapshotManual(widget.bearer);
  }
}
