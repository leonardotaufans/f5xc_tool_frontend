import 'package:flutter/material.dart';

class MyTable extends StatelessWidget {
  const MyTable({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class MyTableRow extends StatelessWidget {
  final Widget child;

  const MyTableRow({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: child,
    );
  }
}
