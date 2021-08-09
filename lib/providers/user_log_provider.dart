import 'package:flutter/material.dart';

enum MenuItem {
  AppDrawer,
  Home,
  PastSchedules,
  AboutUs,
  FloatingActionButton,
  NextScheduleButton,
  PreviousScheduleButton,
  TodayScheduleButton,
}

class UserLogProvider extends ChangeNotifier {
  String? _day;
  String? _userId;
  String? _token;
  Log? _log;


}

class Log {
  final String logInTime;
  String? logOutTime;
  List<String>? clickedTasks;
  List<MenuItem>? clickedMenuItem;

  Log({
    required this.logInTime,
    this.logOutTime,
    this.clickedTasks,
    this.clickedMenuItem,
  });

  void setLogOutTime(String time) {
    logOutTime = time;
  }

  void addClickTask (String taskId) {
    clickedTasks!.add(taskId);
  }

  void addClickedMenuItem(MenuItem menuItem) {
    clickedMenuItem!.add(menuItem);
  }
}
