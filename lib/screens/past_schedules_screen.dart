import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_app/widgets/your_schedule_item.dart';

import '../helpers/helper.dart';
import '../widgets/app_drawer.dart';
import '../widgets/your_schedule_item.dart';
import '../providers/yourSchedule_provider.dart';
import '../providers/connectivity_provider.dart';
import '../screens/no_connection_screen.dart';

class PastSchedulesScreen extends StatefulWidget {
  const PastSchedulesScreen({Key? key}) : super(key: key);
  static const routeName = '/myPastSchedules';

  @override
  _PastSchedulesScreenState createState() => _PastSchedulesScreenState();
}

class _PastSchedulesScreenState extends State<PastSchedulesScreen> {
  bool _isInit = true;

  Future<void> _fetchAndSetYourSchedules() async {
    if (_isInit) {
      await Provider.of<YourScheduleProvider>(context, listen: false)
          .fetchAndSetPastSchedules();
    }
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final PreferredSizeWidget appBar = AppBar(
      title: Text('Your past schedules',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 20.5)),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.white),
    );

    return Consumer<ConnectivityProvider>(builder: (context, connectivity, _) {
      if (connectivity.isOnline != null) {
        return connectivity.isOnline!
            ? Scaffold(
                appBar: appBar,
                body: FutureBuilder(
                  future: _fetchAndSetYourSchedules(),
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Helper.loadingIndicator(context);
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      if (snapshot.hasError) {
                        String homeRoute = '/';
                        return Helper.errorAlertDialog(
                            context,
                            'Something Went wrong, please try again shortly.',
                            homeRoute);
                      } else {
                        return Consumer<YourScheduleProvider>(
                          builder: (ctx, pastScheduleData, _) =>
                              pastScheduleData.pastSchedules.isEmpty
                                  ? Center(
                                      child: Text('No schedules available..'),
                                    )
                                  : Container(
                                      color: Colors.white,
                                      height: (mediaQuery.size.height -
                                          appBar.preferredSize.height -
                                          mediaQuery.padding.top),
                                      child: SingleChildScrollView(
                                        child: Container(
                                          color: Colors.white,
                                          height: (mediaQuery.size.height -
                                              appBar.preferredSize.height -
                                              mediaQuery.padding.top -
                                              75),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: pastScheduleData
                                                .pastSchedules.length,
                                            itemBuilder: (ctx, index) =>
                                                YourScheduleItem(
                                              schedule: pastScheduleData
                                                  .pastSchedules[index],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                        );
                      }
                    } else {
                      String homeRoute = '/';
                      return Helper.errorAlertDialog(
                          context,
                          'Something Went wrong, please try again shortly.',
                          homeRoute);
                    }
                  },
                ),
                drawer: AppDrawer(),
              )
            : NoConnectionScreen();
      }
      return Scaffold(
        body: Center(
          child: Helper.loadingIndicator(context),
        ),
      );
    });
  }
}
