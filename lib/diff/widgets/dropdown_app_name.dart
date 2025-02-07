import 'package:flutter/material.dart';

class DropdownAppName extends StatefulWidget {

  const DropdownAppName({super.key});

  @override
  State<DropdownAppName> createState() => _DropdownAppNameState();
}

class _DropdownAppNameState extends State<DropdownAppName> {
  @override
  Widget build(BuildContext context) {
    return DropdownMenu(dropdownMenuEntries: []);
  }
}
