import 'package:flutter/material.dart';

class AlertTbd extends StatelessWidget {
  const AlertTbd({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text('TBD'),
      content: const Text('To Be Developed'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), child: Text('Close'),
        )
      ],
    );
  }
}
