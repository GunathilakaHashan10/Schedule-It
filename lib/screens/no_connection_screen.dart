import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Scaffold(
      body: Container(
        height: (mediaQuery.size.height - mediaQuery.padding.top),
        width: mediaQuery.size.width,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              height: (mediaQuery.size.height - mediaQuery.padding.top) * 0.15,
              child: Image.asset(
                "assets/images/no-connection.png",
                fit: BoxFit.contain,
                color: Theme.of(context).primaryColor,
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              height: (mediaQuery.size.height - mediaQuery.padding.top) * 0.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Offline',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'Your network is unavailable. Check your data or wifi connection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Container(
                    width: mediaQuery.size.width * 0.7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Material(
                            elevation: 1.0,
                            borderRadius: BorderRadius.circular(30.0),
                            clipBehavior: Clip.antiAlias,
                            color: Colors.white60,
                            child: MaterialButton(
                              minWidth: mediaQuery.size.width * 0.1,
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 15.0, 20.0, 15.0),
                              child: Text(
                                'EXIT',
                                style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontSize: 16.0),
                              ),
                              onPressed: () {
                                SystemNavigator.pop();
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
