import 'package:flutter/material.dart';

import '../helpers/helper.dart';

class EmptyScreen extends StatelessWidget {
  final double appBarHeight;
  final DateTime date;

  const EmptyScreen({Key? key, required this.appBarHeight, required this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
     final mediaQuery = MediaQuery.of(context);
    return Container(
      height: (mediaQuery.size.height - appBarHeight - mediaQuery.padding.top),
      width: mediaQuery.size.width,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/logo_empty_screen.png",
            fit: BoxFit.contain,
          ),
          const SizedBox(
            height: 20.0,
          ),
          Text(
            Helper.isToday(date)
                ? 'Start your today schedule...'
                : 'Plan your future schedule...',
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
