import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/yourSchedule_provider.dart';
import '../providers/connectivity_provider.dart';
import '../screens/past_schedules_screen.dart';
import '../screens/about_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  TextStyle _openSansTextStyle(double fontSize, FontWeight fontWeight, Color color) {
    return TextStyle(
        fontWeight: fontWeight,
        color: color,
        fontSize: fontSize);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: Text('Hi!, ${Provider.of<AuthProvider>(context, listen: false).userEmail!.split('@')[0]}',
                maxLines: 2,
                softWrap: true,
                // overflow: TextOverflow.ellipsis,
                style: _openSansTextStyle(20, FontWeight.w500, Colors.white)),
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          Divider(),
          ListTile(
            leading: Icon(CupertinoIcons.square_favorites, color: Colors.black54),
            title: Text('Past schedules', style: _openSansTextStyle(16, FontWeight.w400, Colors.black)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushNamed(PastSchedulesScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.account_box, color: Colors.black54),
            title: Text('About us', style: _openSansTextStyle(16, FontWeight.w400, Colors.black)),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AboutScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.black54),
            title: Text('Logout', style: _openSansTextStyle(16, FontWeight.w400, Colors.black)),
            onTap: () {
              Provider.of<ScheduleProvider>(context, listen: false).clearData();
              Provider.of<YourScheduleProvider>(context, listen: false).clearData();
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).logout();
              Provider.of<ConnectivityProvider>(context, listen: false).cancelStreamSubscription();
            },
          )
        ],
      ),
    );
  }
}
