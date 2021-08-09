import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppLogoText extends StatelessWidget {
  final BoxConstraints? textConstraints;
  final double fontSize;

  const AppLogoText({Key? key, this.textConstraints, required this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: textConstraints == null ? 40 : textConstraints!.maxHeight * 0.1,
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
            text: 'Schedule',
            style: TextStyle(
              fontFamily: 'SuezOne',
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: Theme.of(context).primaryColor,
            ),
          ),
          TextSpan(
            text: 'It',
            style: TextStyle(
              fontFamily: 'SuezOne',
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              color: Colors.black,
            ),
          ),
        ]),
      ),
    );
  }
}
