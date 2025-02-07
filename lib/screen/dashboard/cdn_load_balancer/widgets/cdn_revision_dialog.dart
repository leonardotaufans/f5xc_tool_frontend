import 'dart:convert';
import 'package:highlight/languages/json.dart' show json;
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart'
    show monokaiSublimeTheme;

class CDNRevisionDialog extends StatefulWidget {
  const CDNRevisionDialog(
      {super.key, required this.jsonData, required this.title});

  final Object jsonData;
  final Widget title;

  @override
  State<CDNRevisionDialog> createState() => _CDNRevisionDialogState();
}

class _CDNRevisionDialogState extends State<CDNRevisionDialog> {
  late CodeController _codeController = CodeController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: widget.title,
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8)
        ),
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: CodeTheme(
            data: CodeThemeData(styles: monokaiSublimeTheme),
            child: CodeField(
              readOnly: true,
              controller: _codeController,
              textStyle: GoogleFonts.sourceCodePro(),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Close'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  String getPrettyJsonString(jsonObject) {
    var encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonObject);
  }

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: getPrettyJsonString(widget.jsonData),
      language: json,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
