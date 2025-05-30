import 'package:calendar/components/custom_text_form_field.dart';
import 'package:calendar/components/max_width.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/screens/login/components/login_button.dart';
import 'package:calendar/screens/login/login_screen.dart';
import 'package:calendar/screens/login/components/login_text_form_field.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

class EmailPassword extends StatefulWidget {
  final PageController pageController;
  final Function(String, String) onSubmit;
  final String submitText;
  final bool hideEmail;
  final bool hidePassword;

  const EmailPassword(
      {Key? key,
      required this.pageController,
      required this.onSubmit,
      required this.submitText,
      this.hideEmail = false,
      this.hidePassword = false})
      : super(key: key);

  @override
  State<EmailPassword> createState() => _EmailPasswordState();
}

class _EmailPasswordState extends State<EmailPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;
  String? error;

  handleOnSubmit() async {
    final isFormValid = _formKey.currentState!.validate();

    if (isFormValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          error = null;
          isLoading = true;
        });
        await widget.onSubmit(email, password);
        _formKey.currentState!.reset();
        setState(() {
          isLoading = false;
        });
      } on AppException catch (err) {
        setState(() {
          error = err.message;
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: MaxWidth(
            maxWidth: maxWidth,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconButton(
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  widget.pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
              ),
              // const SizedBox(height: 16),
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (error != null)
                          Text(
                            'Error: ${error!}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 16),
                        H1(
                          widget.submitText,
                          large: true,
                        ),
                        const SizedBox(height: 24),
                        Form(
                            key: _formKey,
                            child: Column(children: [
                              if (!widget.hideEmail)
                                LoginTextFormField(
                                  hintText: 'Email',
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.none,
                                  keyboardType: TextInputType.emailAddress,
                                  onSaved: (String? value) {
                                    if (value == null) return;
                                    email = value;
                                    value = null;
                                  },
                                  validator: (String? value) {
                                    if (value == null) {
                                      return 'Please enter an email';
                                    }
                                    if (!EmailValidator.validate(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                              if (!widget.hidePassword)
                                LoginTextFormField(
                                  hintText: 'Password',
                                  textInputAction: TextInputAction.done,
                                  textCapitalization: TextCapitalization.none,
                                  obscureText: true,
                                  // onSubmitted: (_) => handleOnSubmit, // cant get this to work
                                  onSaved: (String? value) {
                                    if (value == null) return;
                                    password = value;
                                    value = null;
                                  },
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    return null;
                                  },
                                ),
                            ])),
                        const SizedBox(height: 16),
                        LoginScreenButton(
                          text: widget.submitText,
                          icon: Icons.login_rounded,
                          onTap: handleOnSubmit,
                          isLoading: isLoading,
                        ),
                      ]))
            ])));
  }
}
