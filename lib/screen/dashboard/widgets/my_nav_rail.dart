import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyNavRail extends StatefulWidget {
  const MyNavRail({super.key, required this.indexCallback});

  final Function indexCallback;

  @override
  State<MyNavRail> createState() => _MyNavRailState();
}

class _MyNavRailState extends State<MyNavRail> {
  late int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(),
        ),
        // Navigation Rail
        SingleChildScrollView(
          child: IntrinsicHeight(
            child: NavigationRail(
          
              leading: VerticalDivider(),
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (int index) {
                widget.indexCallback(index);
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedIndex: _selectedIndex,
              destinations: const [
                NavigationRailDestination(
                    icon: Icon(Icons.http_outlined),
                    selectedIcon: Icon(Icons.http),
                    label: Text('HTTP LB')),
                NavigationRailDestination(
                    icon: Icon(Icons.account_tree_outlined),
                    selectedIcon: Icon(Icons.account_tree),
                    label: Text('TCP LB')),
                NavigationRailDestination(
                    icon: Icon(Icons.cloud_outlined),
                    selectedIcon: Icon(Icons.cloud),
                    label: Text('CDN LB')),
                NavigationRailDestination(
                    icon: Icon(Icons.compare_outlined),
                    selectedIcon: Icon(Icons.compare_outlined),
                    label: Text(
                      'LB\nDiff',
                      textAlign: TextAlign.center,
                    )),
                NavigationRailDestination(
                    icon: Icon(Icons.supervised_user_circle_outlined),
                    selectedIcon: Icon(Icons.supervised_user_circle_rounded),
                    label: Text('Users')),
                NavigationRailDestination(
                    icon: Icon(Icons.history_edu_outlined),
                    selectedIcon: Icon(Icons.history_edu_rounded),
                    label: Text(
                      'Event\nLogs',
                      textAlign: TextAlign.center,
                    )),
              ],
            ),
          ),
        ),
        Spacer(),
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () async {
                      await FlutterSecureStorage().deleteAll();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    icon: const Icon(Icons.logout)),
                Text(
                  'Logout',
                  style: Theme.of(context).textTheme.bodySmall,
                )
              ],
            ))
      ],
    );
  }
}
