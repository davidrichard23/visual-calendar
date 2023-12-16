import 'package:calendar/components/text/paragraph.dart';
import 'package:flutter/material.dart';

class LoginScreenButton extends StatelessWidget {
  const LoginScreenButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final Function() onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    handleOnTap() {
      if (isLoading) return;
      onTap();
    }

    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ElevatedButton(
            onPressed: handleOnTap,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              foregroundColor: theme.primaryColor,
              shadowColor: Color.fromARGB(100, 0, 135, 101),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(56),
              ),
              elevation: 15.0,
            ),
            child: Stack(alignment: AlignmentDirectional.center, children: [
              Opacity(
                  opacity: isLoading ? 0 : 1,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: Icon(icon,
                                size: 32,
                                color: const Color.fromRGBO(0, 69, 77, 1))),
                        Flexible(
                            child: Paragraph(
                          text,
                          small: true,
                          // color: Colors.white,
                        )),
                      ])),
              if (isLoading)
                const Center(
                  child: SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(100, 0, 135, 101),
                      )),
                )
            ])));
  }
}
