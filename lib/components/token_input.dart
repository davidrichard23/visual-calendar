import 'dart:async';

import 'package:calendar/components/buttons/primary_button.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

class TokenInput extends StatefulWidget {
  final Future<void> Function(String) onSubmit;
  final bool inverseColor;

  const TokenInput(
      {Key? key, required this.onSubmit, this.inverseColor = false})
      : super(key: key);

  @override
  State<TokenInput> createState() => _TokenInputState();
}

class _TokenInputState extends State<TokenInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _textNode = FocusNode();
  String code = '';
  String? error;
  bool isLoading = false;

  void onCodeInput(String value) {
    setState(() {
      code = value.toUpperCase();
    });
  }

  void handleSubmit() async {
    try {
      setState(() {
        error = null;
        isLoading = true;
      });
      await widget.onSubmit(code);
      setState(() => isLoading = false);
    } on AppException catch (err) {
      setState(() {
        error = err.message;
        isLoading = false;
      });
    }
  }

  List<Widget> getField() {
    final List<Widget> result = <Widget>[];
    for (int i = 1; i <= 8; i++) {
      result.add(Column(
        children: <Widget>[
          if (code.length >= i)
            H1(
              code[i - 1],
              large: true,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 5.0,
            ),
            child: Container(
              height: 3.0,
              width: (300 / 9 - 5),
              color: const Color.fromRGBO(0, 69, 77, 1),
            ),
          ),
        ],
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: <Widget>[
          const H1(
            'Join Team',
            large: true,
          ),
          const SizedBox(
            height: 20,
          ),
          const Paragraph(
            'Enter your 8 digit invite code.',
          ),
          const SizedBox(height: 20),
          if (error != null)
            Text(
              'Error: ${error!}',
              style: const TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            width: 320,
            child: Stack(
              children: <Widget>[
                Opacity(
                  opacity: 1,
                  child: TextFormField(
                    controller: _controller,
                    focusNode: _textNode,
                    autofocus: true,
                    // keyboardType: TextInputType.number,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: onCodeInput,
                    maxLength: 8,
                    autocorrect: false,
                    showCursor: false,
                    style: const TextStyle(color: Colors.transparent),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: getField(),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
              width: 300,
              child: PrimaryButton(
                  onPressed: handleSubmit,
                  isLoading: isLoading,
                  color: widget.inverseColor ? Colors.white : null,
                  child: const Paragraph('Join Team')))
        ],
      ),
    );
  }
}
