import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/helper.dart';
import '../widgets/empty_screen.dart';
import '../widgets/schedule_item.dart';
import '../providers/schedule_provider.dart';

class ScheduleScreen extends StatefulWidget {
  final DateTime dateTime;
  final double appBarHeight;

  ScheduleScreen({required this.dateTime, required this.appBarHeight});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _isInit = true;

  Future<void> _fetchTaskList(BuildContext context) async {
    if (_isInit) {
      Provider.of<ScheduleProvider>(context, listen: false).clearData();
      await Provider.of<ScheduleProvider>(context, listen: false)
          .fetchAndSetTasksForADay(widget.dateTime);
    }
    _isInit = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return FutureBuilder(
      future: _fetchTaskList(context),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.white,
            height: (mediaQuery.size.height -
                widget.appBarHeight -
                mediaQuery.padding.top),
            child: Helper.loadingIndicator(context),
          );
          // return Helper.loadingIndicator(context);
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            String homeRoute = '/';
            return Helper.errorAlertDialog(
                context,
                'Something Went wrong, please check your internet connection.',
                homeRoute);
          } else {
            return Consumer<ScheduleProvider>(
                builder: (ctx, scheduleData, _) => scheduleData.taskList.isEmpty
                    ? EmptyScreen(
                        appBarHeight: widget.appBarHeight,
                        date: widget.dateTime,
                      )
                    : Container(
                        color: Colors.white,
                        height: (mediaQuery.size.height -
                            widget.appBarHeight -
                            mediaQuery.padding.top),
                        child: SingleChildScrollView(
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/logo_empty_screen.png"),
                                fit: BoxFit.contain,
                                colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.09), BlendMode.dstIn),
                              ),
                              color: Colors.white,
                            ),
                            // color: Colors.white,
                            height: (mediaQuery.size.height -
                                widget.appBarHeight -
                                mediaQuery.padding.top -
                                75),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: scheduleData.taskList.length,
                              itemBuilder: (ctx, index) =>
                                  ChangeNotifierProvider.value(
                                value: scheduleData.taskList[index],
                                child: ScheduleItem(
                                  ancestorContext: context,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
            );
          }
        } else {
          String homeRoute = '/';
          return Helper.errorAlertDialog(context,
              'Something Went wrong, please try again shortly.', homeRoute);
        }
      },
    );
  }
}
