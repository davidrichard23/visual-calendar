import 'package:calendar/components/custom_text_form_field.dart';
import 'package:calendar/components/token_input.dart';
import 'package:calendar/screens/login/login_button.dart';
import 'package:calendar/screens/login/login_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

class InviteToken extends StatefulWidget {
  final Function(String) onSubmit;
  final PageController pageController;
  final bool hideBackButton;

  const InviteToken(
      {Key? key,
      required this.onSubmit,
      required this.pageController,
      this.hideBackButton = false})
      : super(key: key);

  @override
  State<InviteToken> createState() => _InviteTokenState();
}

class _InviteTokenState extends State<InviteToken> {
  bool isLoading = false;

  Future<void> handleSubmit(String token) async {
    try {
      setState(() => isLoading = true);
      await widget.onSubmit(token);
      setState(() => isLoading = false);
    } catch (err) {
      setState(() => isLoading = false);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!widget.hideBackButton)
                IconButton(
                  onPressed: () {
                    if (isLoading) return;
                    FocusManager.instance.primaryFocus?.unfocus();
                    widget.pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new),
                  color: Colors.white,
                ),
              // const SizedBox(height: 16),
              TokenInput(onSubmit: handleSubmit, inverseColor: true)
            ])));
  }
}
