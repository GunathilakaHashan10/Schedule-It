import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../screens/past_schedule_preview_screen.dart';
import '../providers/genericSchedule.dart';


class YourScheduleItem extends StatelessWidget {
  final GenericSchedule schedule;

  const YourScheduleItem({Key? key, required this.schedule})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
          Navigator.of(context).pushNamed(PastSchedulePreviewScreen.routeName, arguments: [schedule.scheduleId, schedule.date]);
      },
      child: Card(
        elevation: 1,
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: FittedBox(
                child: Text(
                  schedule.taskCount.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          title: Text(DateFormat.yMMMd().format(DateTime.parse(schedule.date!)), style: TextStyle(fontWeight: FontWeight.w500),),
          subtitle: Text(DateFormat.EEEE().format(DateTime.parse(schedule.date!))),
        ),
      ),
    );
  }
}
