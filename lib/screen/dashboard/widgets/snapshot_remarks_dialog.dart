import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/snapshot_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SnapshotRemarksDialog extends StatefulWidget {
  final SnapshotModel model;

  const SnapshotRemarksDialog({super.key, required this.model});

  @override
  State<SnapshotRemarksDialog> createState() => _SnapshotRemarksDialogState();
}

class _SnapshotRemarksDialogState extends State<SnapshotRemarksDialog> {
  final ExpansionTileController _httpControl = ExpansionTileController();
  final ExpansionTileController _tcpControl = ExpansionTileController();
  final ExpansionTileController _cdnControl = ExpansionTileController();

  @override
  Widget build(BuildContext context) {
    SnapshotModel model = widget.model;
    bool noUpdates = model.result == "No updates found";
    return AlertDialog(
        title: Text('Snapshot Completed'),
        content: noUpdates ? Text("No updates found") : contentRemarks(model),
        actions: noUpdates
            ? [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'))
              ]
            : []);
  }

  Widget contentRemarks(SnapshotModel model) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView(
        shrinkWrap: true,
        children: [
          Text('Update(s) have been pushed to the revision database. '
              '\nPlease enter the snapshot remarks.'),
          SizedBox(
            height: 16,
          ),
          ListView(
            shrinkWrap: true,
            children: [
              ExpansionTile(
                controller: _httpControl,
                onExpansionChanged: (isExpanded) {
                  if (isExpanded) {
                    _tcpControl.collapse();
                    _cdnControl.collapse();
                  }
                },
                leading: Icon(Icons.http),
                shape: const Border(),
                title: Text('HTTP Load Balancer'),
                initiallyExpanded: false,
                children: [httpSnapshot(model)],
              ),
              ExpansionTile(
                controller: _tcpControl,
                onExpansionChanged: (isExpanded) {
                  if (isExpanded) {
                    _httpControl.collapse();
                    _cdnControl.collapse();
                  }
                },
                leading: Icon(Icons.account_tree),
                shape: const Border(),
                title: Text('TCP Load Balancer'),
                initiallyExpanded: false,
                children: [tcpSnapshot(model)],
              ),
              ExpansionTile(
                controller: _cdnControl,
                onExpansionChanged: (isExpanded) {
                  if (isExpanded) {
                    _tcpControl.collapse();
                    _httpControl.collapse();
                  }
                },
                leading: Icon(Icons.cloud),
                shape: const Border(),
                title: Text('CDN Load Balancer'),
                initiallyExpanded: false,
                children: [cdnSnapshot(model)],
              ),
            ],
          )
        ],
      ),
    );
  }

  httpSnapshot(SnapshotModel model) {
    ExpansionTileController newProd = ExpansionTileController();
    ExpansionTileController updProd = ExpansionTileController();
    ExpansionTileController newStg = ExpansionTileController();
    ExpansionTileController updStg = ExpansionTileController();
    return Card(
      child: ListView(
        padding: EdgeInsets.all(8),
        shrinkWrap: true,
        children: [
          ExpansionTile(
            controller: newProd,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                updProd.collapse();
                newStg.collapse();
                updStg.collapse();
              }
            },
            shape: const Border(),
            title: Text('New Production'),
            children: [
              ...model.httpLb?.newProd
                      ?.map((val) => ContentRemarks(
                            contents: val,
                            environment: "production",
                            path: 'http_lb',
                          ))
                      .toList() ??
                  [Text('No updates found')],
            ],
          ),
          SizedBox(
            height: 8,
          ),
          ExpansionTile(
            controller: newStg,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                newProd.collapse();
                // newStg.collapse();
                updProd.collapse();
                updStg.collapse();
              }
            },
            shape: const Border(),
            title: Text('New Staging'),
            children: [
              ...model.httpLb?.newStaging
                      ?.map((val) => ContentRemarks(
                            contents: val,
                            environment: "staging",
                            path: 'http_lb',
                          ))
                      .toList() ??
                  [Text('No updates found')],
            ],
          ),
          ExpansionTile(
            controller: updProd,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                newProd.collapse();
                newStg.collapse();
                // updProd.collapse();
                updStg.collapse();
              }
            },
            shape: const Border(),
            title: Text('Updates Production'),
            children: [
              ...model.httpLb?.updateProd
                      ?.map((val) => ContentRemarks(
                            contents: val,
                            environment: "production",
                            path: 'http_lb',
                          ))
                      .toList() ??
                  [Text('No updates found')],
            ],
          ),
          ExpansionTile(
            controller: updStg,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                newProd.collapse();
                newStg.collapse();
                updProd.collapse();
                // updStg.collapse();
              }
            },
            shape: const Border(),
            title: Text('Updates Staging'),
            children: [
              ...model.httpLb?.updateStaging
                      ?.map((val) => ContentRemarks(
                            contents: val,
                            environment: "staging",
                            path: 'http_lb',
                          ))
                      .toList() ??
                  [Text('No updates found')],
            ],
          ),
        ],
      ),
    );
  }

  tcpSnapshot(SnapshotModel model) {
    ExpansionTileController newProd = ExpansionTileController();
    ExpansionTileController updProd = ExpansionTileController();
    ExpansionTileController newStg = ExpansionTileController();
    ExpansionTileController updStg = ExpansionTileController();
    return Card(
      child: ListView(
        padding: EdgeInsets.all(8),
        shrinkWrap: true,
        children: [
          ExpansionTile(
            controller: newProd,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                // newProd.collapse();
                newStg.collapse();
                updProd.collapse();
                updStg.collapse();
              }
            },
            shape: const Border(),
            title: Text('New Production'),
            initiallyExpanded: true,
            children: [
              ...model.tcpLb?.newProd
                      ?.map((val) => ContentRemarks(
                            contents: val,
                            environment: "production",
                            path: 'tcp_lb',
                          ))
                      .toList() ??
                  [Text('No updates found')],
            ],
          ),
          SizedBox(
            height: 8,
          ),
          ExpansionTile(
            controller: newStg,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                newProd.collapse();
                // newStg.collapse();
                updProd.collapse();
                updStg.collapse();
              }
            },
            shape: const Border(),
            title: Text('New Staging'),
            children: [
              ...model.tcpLb?.newStaging
                      ?.map((val) => ContentRemarks(
                            contents: val,
                            environment: "staging",
                            path: 'tcp_lb',
                          ))
                      .toList() ??
                  [Text('No updates found')],
            ],
          ),
          ExpansionTile(
            controller: updProd,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                newProd.collapse();
                newStg.collapse();
                // updProd.collapse();
                updStg.collapse();
              }
            },
            shape: const Border(),
            title: Text('Updates Production'),
            children: [
              ...model.tcpLb?.updateProd
                      ?.map((val) => ContentRemarks(
                            contents: val,
                            environment: "production",
                            path: 'tcp_lb',
                          ))
                      .toList() ??
                  [Text('No updates found')],
            ],
          ),
          ExpansionTile(
            controller: updStg,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                newProd.collapse();
                newStg.collapse();
                updProd.collapse();
                // updStg.collapse();
              }
            },
            shape: const Border(),
            title: Text('Updates Staging'),
            children: [
              ...model.tcpLb?.updateStaging
                      ?.map((val) => ContentRemarks(
                            contents: val,
                            environment: "staging",
                            path: 'tcp_lb',
                          ))
                      .toList() ??
                  [Text('No updates found')],
            ],
          ),
        ],
      ),
    );
  }

  cdnSnapshot(SnapshotModel model) {
    ExpansionTileController newProd = ExpansionTileController();
    ExpansionTileController updProd = ExpansionTileController();
    ExpansionTileController newStg = ExpansionTileController();
    ExpansionTileController updStg = ExpansionTileController();
    return Card(
      child: ListView(
        padding: EdgeInsets.all(8),
        shrinkWrap: true,
        children: [
          ExpansionTile(
            controller: newProd,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                // newProd.collapse();
                newStg.collapse();
                updProd.collapse();
                updStg.collapse();
              }
            },
            shape: const Border(),
            title: Text('New Production'),
            initiallyExpanded: true,
            children: [
              ...model.cdnLb?.newProd
                      ?.map((val) => ContentRemarks(
                            contents: val,
                            environment: "production",
                            path: 'cdn_lb',
                          ))
                      .toList() ??
                  [Text('No updates found')],
            ],
          ),
          SizedBox(
            height: 8,
          ),
          ExpansionTile(
            controller: newStg,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                newProd.collapse();
                // newStg.collapse();
                updProd.collapse();
                updStg.collapse();
              }
            },
            shape: const Border(),
            title: Text('New Staging'),
            children: [
              ...model.cdnLb?.newStaging
                      ?.map((val) => ContentRemarks(
                            contents: val,
                            environment: "staging",
                            path: 'cdn_lb',
                          ))
                      .toList() ??
                  [Text('No updates found')],
            ],
          ),
          ExpansionTile(
            controller: updProd,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                newProd.collapse();
                newStg.collapse();
                // updProd.collapse();
                updStg.collapse();
              }
            },
            shape: const Border(),
            title: Text('Updates Production'),
            children: [
              ...model.cdnLb?.updateProd
                      ?.map((val) => ContentRemarks(
                            contents: val,
                            environment: "production",
                            path: 'cdn_lb',
                          ))
                      .toList() ??
                  [Text('No updates found')],
            ],
          ),
          ExpansionTile(
            controller: updStg,
            onExpansionChanged: (isExpanded) {
              if (isExpanded) {
                newProd.collapse();
                newStg.collapse();
                updProd.collapse();
                // updStg.collapse();
              }
            },
            shape: const Border(),
            title: Text('Updates Staging'),
            children: [
              ...model.cdnLb?.updateStaging
                      ?.map((val) => ContentRemarks(
                            contents: val,
                            environment: "production",
                            path: 'cdn_lb',
                          ))
                      .toList() ??
                  [Text('No updates found')],
            ],
          ),
        ],
      ),
    );
  }
}

class ContentRemarks extends StatefulWidget {
  final SnapshotContents contents;
  final String path;
  final String environment;

  const ContentRemarks(
      {super.key,
      required this.contents,
      required this.path,
      required this.environment});

  @override
  State<ContentRemarks> createState() => _ContentRemarksState();
}

class _ContentRemarksState extends State<ContentRemarks> {
  late TextEditingController _controller;
  bool isFilled = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: "System generated");
  }

  @override
  Widget build(BuildContext context) {
    SnapshotContents contents = widget.contents;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Card.outlined(
        child: ListView(
          padding: EdgeInsets.all(8),
          shrinkWrap: true,
          children: (!isFilled)
              ? [
                  ListTile(
                    title: Text('Load Balancer Name'),
                    subtitle: Text('${contents.name}'.toUpperCase()),
                  ),
                  ListTile(
                    title: Text('New version'),
                    subtitle: Text('${contents.newVersion}'),
                  ),
                  Visibility(
                      visible: contents.previousVersion != null,
                      child: ListTile(
                        title: Text('Previous Version'),
                        subtitle: Text('${contents.previousVersion}'),
                      )),
                  SizedBox(height: 16),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    controller: _controller,
                    onEditingComplete: onSubmitted,
                    maxLines: 4,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        label: Text('Enter Remarks')),
                  ),
                  SizedBox(height: 16),
                  OutlinedButton(
                      onPressed: onSubmitted, child: Text('Submit'))
                ]
              : [
                  ListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                          )),
                      title: Text('Remarks has been submitted.'))
                ],
        ),
      ),
    );
  }

  void onSubmitted() {
    if (_controller.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: Colors.red.shade900,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text('Error'),
                  ],
                ),
                content: Text('Remarks cannot be empty.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Dismiss'))
                ],
              ));
      return;
    }
    FlutterSecureStorage().read(key: 'auth').then((value) {
      SqlQueryHelper().snapshotRemarks(value ?? '', widget.contents.uid ?? '',
          widget.environment, widget.path, _controller.text);
    });

    setState(() {
      isFilled = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
