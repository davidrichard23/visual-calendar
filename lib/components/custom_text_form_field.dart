import 'dart:async';
import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String? hintText;
  final int? minLines;
  final int? maxLines;
  final String? initialValue;
  final bool? enabled;
  final bool? obscureText;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Color? fillColor;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;
  final TextCapitalization textCapitalization;
  final TextInputType keyboardType;

  const CustomTextFormField(
      {this.hintText,
      this.minLines = 1,
      this.maxLines = 1,
      this.initialValue,
      this.enabled,
      this.obscureText = false,
      this.borderRadius = 8,
      this.boxShadow,
      this.fillColor = Colors.white,
      this.onSaved,
      this.validator,
      this.textInputAction,
      this.onSubmitted,
      this.textCapitalization = TextCapitalization.sentences,
      this.keyboardType = TextInputType.text,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          boxShadow: boxShadow,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius!)),
        ),
        child: TextFormField(
            minLines: minLines,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: fillColor,
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
            initialValue: initialValue,
            enabled: enabled,
            obscureText: obscureText!,
            onSaved: onSaved,
            validator: validator,
            textInputAction: textInputAction,
            onFieldSubmitted: onSubmitted,
            textCapitalization: textCapitalization,
            keyboardType: keyboardType));
  }
}
