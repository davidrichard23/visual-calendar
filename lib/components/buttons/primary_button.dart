import 'dart:developer';

import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final Widget child;
  final Function()? onPressed;
  bool isLoading;
  bool isDisabled;
  bool medium;
  bool small;
  bool outlined;
  Color? color;

  PrimaryButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.medium = false,
    this.small = false,
    this.outlined = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double height = small
        ? 30
        : medium
            ? 40
            : 50;

    return ElevatedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,
      style: ButtonStyle(
          elevation: MaterialStateProperty.all(outlined ? 0 : 2),
          side: outlined
              ? MaterialStateProperty.all(
                  BorderSide(color: theme.primaryColor, width: 2))
              : null,
          backgroundColor: MaterialStateProperty.all(outlined
              ? Colors.white
              : isDisabled || isLoading
                  ? Colors.grey[300]
                  : color ?? theme.primaryColor),
          minimumSize: MaterialStateProperty.all(Size.fromHeight(height)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          )),
          textStyle: MaterialStateProperty.all(
              const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 3))),
      child: isLoading
          ? SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(
                color: theme.primaryColor,
              ),
            )
          : child,
    );
  }
}
