import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/add_new_task.dart';
import '../providers/task.dart';
import '../widgets/task_overview.dart';

class Helper {
  static String convertTimeOfDayToString(TimeOfDay timeOfDay) {
    int hours = timeOfDay.hour;
    int minutes = timeOfDay.minute;
    String minutesStr;
    if (minutes < 10) {
      minutesStr = '0$minutes';
    } else {
      minutesStr = '$minutes';
    }
    return '$hours:$minutesStr';
  }

  static TimeOfDay convert24hrTimeToTimeOfDay(String time) {
    List<String> timeArray = time.split(':');
    int hours = int.parse(timeArray[0]);
    int minutes = int.parse(timeArray[1]);
    return TimeOfDay(hour: hours, minute: minutes);
  }

  static String convert24hrTimeToLocalizeTime(String time) {
    // 13:30
    List<String> timeArray = time.split(':'); // ['13', '30']
    int hours = int.parse(timeArray[0]); // 13
    int minutes = int.parse(timeArray[1]); // 30
    String hoursStr;
    String minutesStr;
    String period = 'AM';
    if (hours > 12) {
      hours = hours - 12;
      period = 'PM';
    }
    if (hours == 12) {
      period = 'PM';
    }
    if (hours == 0) {
      hours = 12;
    }
    if (hours < 10) {
      hoursStr = '0$hours';
    } else {
      hoursStr = '$hours';
    }
    if (minutes < 10) {
      minutesStr = '0$minutes';
    } else {
      minutesStr = '$minutes';
    }
    return '$hoursStr:$minutesStr $period';
  }

  static void showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }

  static double convertTimeToDouble(TimeOfDay time) {
    return time.hour.toDouble() + (time.minute.toDouble() / 60);
  }

  static double calculateDurationInSeconds(
      TimeOfDay startTime, TimeOfDay endTime) {
    double durationInSeconds = (Helper.convertTimeToDouble(endTime) -
            Helper.convertTimeToDouble(startTime)) *
        3600;
    return double.parse(durationInSeconds.toStringAsFixed(2));
  }

  static bool isDateTimeEqual(DateTime dateOne, DateTime dateTwo) {
    var formatter = DateFormat('yyyy-MM-dd');
    if (formatter.format(dateOne) == formatter.format(dateTwo)) {
      return true;
    }
    return false;
  }

  static void showAddNewTask(
      {required BuildContext context,
      required bool isEditing,
      Task? task,
      required DateTime date}) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) {
          return AddNewTask(
            isEditing: isEditing,
            task: task,
            date: date,
          );
        });
  }

  static bool isToday(DateTime date) {
    var now = DateTime.now();
    if (now.difference(date).inDays == 0) {
      return true;
    }
    return false;
  }

  static bool isFutureDay(DateTime date) {
    var now = DateTime.now();
    if (now.difference(date).inDays < 0) {
      return true;
    }
    return false;
  }

  static void showTaskOverviewDialog(
      {required BuildContext context,
      required Task task,
      required Color color}) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => TaskOverview(
              task: task,
              color: color,
            ));
  }

  static Widget loadingIndicator(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  static Widget errorAlertDialog(
      BuildContext context, String message, String route) {
    return AlertDialog(
      title: Text('An Error Occurred!'),
      content: Text(message),
      actions: [
        MaterialButton(
          child: Text('Okay'),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(route);
          },
        )
      ],
    );
  }

  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: [
          MaterialButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }
}
