import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/revision_model.dart';
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
    // return WillPopScope(
    //   onWillPop: () async {
    //     ListRevisionModel model = await snapshot();
    //     if (model.responseCode > 201)
    //   },
    // );
    return WillPopScope(
      onWillPop: () async {
        final NavigatorState navigator = Navigator.of(context);
        await snapshot().then((value) {
          print(value);
          navigator.pop();
        });
        return true;
      },
      child: AlertDialog(
        content:
            SizedBox(width: 60, height: 60, child: CircularProgressIndicator()),
      ),
    );
  }

  Future<ListRevisionModel> snapshot() async {
    print('snapshot doko???');
    return await SqlQueryHelper().snapshotManual(widget.bearer);
  }
}
