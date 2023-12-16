import 'package:calendar/components/max_width.dart';
import 'package:calendar/components/text/h1.dart';
import 'package:calendar/components/text/paragraph.dart';
import 'package:calendar/screens/login/login_screen.dart';
import 'package:flutter/material.dart';

class CheckEmail extends StatelessWidget {
  final PageController? pageController;

  const CheckEmail({Key? key, this.pageController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: MaxWidth(
            maxWidth: maxWidth,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (pageController != null)
                IconButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    pageController!.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                  icon: const Icon(Icons.arrow_back_ios_new),
                  color: Colors.white,
                ),
              // const SizedBox(height: 16),
              Container(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        SizedBox(height: 16),
                        H1(
                          'Check your email',
                          large: true,
                        ),
                        SizedBox(height: 24),
                        Paragraph(
                          'We sent you an email with a link to reset your password. Click the link in the email to continue.',
                          center: true,
                        ),
                      ]))
            ])));
  }
}
