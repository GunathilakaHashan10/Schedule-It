import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final BoxConstraints? logoConstraints;
  const AppLogo({Key? key, this.logoConstraints}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: logoConstraints!.maxHeight * 0.4,
      alignment: Alignment.center,
      child: Image.asset(
        "assets/images/logo.png",
        fit: BoxFit.contain,
      ),
    );
  }
}
