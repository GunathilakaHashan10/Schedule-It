import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../widgets/app_logo_text.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  static const routeName = '/aboutUs';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final PreferredSizeWidget appBar = AppBar(
      title: Text('About us',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 20.5)),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.white),
    );

    return Scaffold(
      appBar: appBar,
      body: Container(
        padding: EdgeInsets.all(10.0),
        color: Colors.white,
        height: (mediaQuery.size.height -
            appBar.preferredSize.height -
            mediaQuery.padding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                    text: 'Schedule',
                    style: TextStyle(
                      fontFamily: 'SuezOne',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  TextSpan(
                      text: 'It',
                      style: TextStyle(
                        fontFamily: 'SuezOne',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                  TextSpan(
                      text: ' v1.0.2',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      )),
                ]),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              'The whole purpose of this ScheduleIt application is to gather real user data which are related with daily scheduling.'
              'These user data will be used for the evaluation of a research project which is conducted by a group of students in University of Moratuwa.'
              ' We guarantee that your data is safe with us. And eventually all users of this application directly contribute towards the success of this research.\n'
              'And we would like to express our gratitude to all users.',
              style: TextStyle(
                  fontSize: 16, height: 2, fontWeight: FontWeight.w300),
              textAlign: TextAlign.justify,
              softWrap: true,
            ),
            const SizedBox(
              height: 20.0,
            ),
            const Text(
              'Credits: ',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              textAlign: TextAlign.start,
            ),
            const Text(
              'Hashan Gunathilaka\nDulaksha Gunarathne\nPavindu Lakshan\nDevindi Jayathilaka',
              style: TextStyle(
                  fontSize: 16, height: 2, fontWeight: FontWeight.w300),
              textAlign: TextAlign.start,
              softWrap: true,
            ),
          ],
        ),
      ),
    );
  }
}
