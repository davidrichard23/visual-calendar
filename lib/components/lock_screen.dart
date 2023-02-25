import 'dart:async';

import 'package:flutter/material.dart';
import 'package:passcode_screen/passcode_screen.dart';

class LockScreen extends StatelessWidget {
  final Function(bool) onPasscodeEntered;

  LockScreen(this.onPasscodeEntered, {Key? key}) : super(key: key);

  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  @override
  Widget build(BuildContext context) {
    handlePasscode(String enteredPasscode) {
      bool isValid = '111111' == enteredPasscode;
      onPasscodeEntered(isValid);
    }

    return PasscodeScreen(
      title: const Text('Unlock Caregiver'),
      passwordEnteredCallback: handlePasscode,
      cancelButton: const Text('Cancel'),
      deleteButton: const Text('Delete'),
      shouldTriggerVerification: _verificationNotifier.stream,
    );
  }
}
