import 'package:calendar/components/custom_text_form_field.dart';
import 'package:flutter/material.dart';

class LoginTextFormField extends CustomTextFormField {
  const LoginTextFormField(
      {super.borderRadius = 16,
      super.fillColor = const Color.fromRGBO(255, 255, 255, 0.8),
      super.boxShadow = const [
        BoxShadow(
          color: Color.fromARGB(100, 0, 135, 101),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
      super.key,
      super.hintText,
      super.minLines,
      super.maxLines,
      super.initialValue,
      super.enabled,
      super.obscureText,
      super.onSaved,
      super.validator,
      super.textInputAction,
      super.onSubmitted,
      super.textCapitalization,
      super.keyboardType});
}
