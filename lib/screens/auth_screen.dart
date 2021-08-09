import 'package:flutter/material.dart';

import '../widgets/app_logo.dart';
import '../widgets/app_logo_text.dart';
import '../widgets/auth_form.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: mediaQuery.size.height - mediaQuery.padding.top,
          width: mediaQuery.size.width,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              return SingleChildScrollView(
                child: Container(
                  height: mediaQuery.size.height - mediaQuery.padding.top,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppLogo(logoConstraints: constraints),
                      AppLogoText(textConstraints: constraints, fontSize: 36),
                      AuthForm(authConstraints: constraints),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


