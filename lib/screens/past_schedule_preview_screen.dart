import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../helpers/helper.dart';
import '../widgets/task_item.dart';
import '../providers/yourSchedule_provider.dart';
import '../providers/connectivity_provider.dart';
import '../screens/no_connection_screen.dart';

class PastSchedulePreviewScreen extends StatefulWidget {
  const PastSchedulePreviewScreen({Key? key}) : super(key: key);

  static const routeName = '/pastSchedulePreview';

  @override
  _PastSchedulePreviewScreenState createState() => _PastSchedulePreviewScreenState();
}

class _PastSchedulePreviewScreenState extends State<PastSchedulePreviewScreen> {
  bool _isInit = true;
  bool _isFetchedRouteData = false;
  String? _date;
  String? _scheduleId;

  Future<void> _fetchAndSetTasks() async {
    if (_isInit) {
      if (_isInit) {
        if (_scheduleId != null) {
          await Provider.of<YourScheduleProvider>(context, listen: false)
              .fetchAndSetPastTaskList(_scheduleId!);
        }
      }
      _isInit = false;
    }
  }

  @override
  void didChangeDependencies() {
    if (!_isFetchedRouteData) {
      final List<dynamic> scheduleData =
      ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      if (scheduleData.isNotEmpty) {
        setState(() {
          _date =
              DateFormat.yMMMMEEEEd().format(DateTime.parse(scheduleData[1]!));
          _scheduleId = scheduleData[0]!;
        });
      }
    }
    _isFetchedRouteData = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final PreferredSizeWidget appBar = AppBar(
      title: Text(_date!,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 20.5)),
      backgroundColor: Theme.of(context).accentColor,
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.white),
    );

    return Consumer<ConnectivityProvider>(builder: (context, connectivity, _) {
      if (connectivity.isOnline != null) {
        return connectivity.isOnline!
            ? Scaffold(
          appBar: appBar,
          body: FutureBuilder(
            future: _fetchAndSetTasks(),
            builder:
                (BuildContext context, AsyncSnapshot<void> snapshot) {
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
                    builder: (ctx, scheduleData, _) => scheduleData.pastTaskList.isEmpty ?
                    Center(
                      child: Text('No tasks available..'),
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
                            itemCount: scheduleData.pastTaskList.length,
                            itemBuilder: (ctx, index) =>
                                TaskItem(task: scheduleData.pastTaskList[index]),
                          ),
                        ),
                      ),
                    )

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
