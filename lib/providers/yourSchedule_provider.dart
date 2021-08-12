import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../helpers/secrets.dart';
import 'task.dart';
import 'genericSchedule.dart';

class YourScheduleProvider with ChangeNotifier {
  final String? _authToken;
  final String? _userId;
  List<GenericSchedule> _pastSchedules = [];
  List<Task> _pastTaskList = [];

  YourScheduleProvider(
    this._authToken,
    this._userId,
    this._pastSchedules,
    this._pastTaskList,
  );

  List<GenericSchedule> get pastSchedules {
    _pastSchedules.sort((schA, schB) => schB.date!.compareTo(schA.date!));
    return [..._pastSchedules];
  }

  List<Task> get pastTaskList {
    return [..._pastTaskList];
  }


  Future<void> fetchAndSetPastSchedules() async {
    String yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(Duration(days: 1)));
    final url =
        '${Secrets.FIREBASE_URL}/schedules/$_userId.json?auth=$_authToken&orderBy="date"&endAt="$yesterday"';
    try {
      final response = await http.get(Uri.parse(url));
      final yourSchedules = json.decode(response.body) as Map<String, dynamic>;
      if (yourSchedules.isEmpty) {
        return;
      }
      final List<GenericSchedule> loadedSchedules = [];
      yourSchedules.forEach((scheduleId, scheduleData) {
        if (scheduleData['tasks'] != null) {
          loadedSchedules.add(GenericSchedule(
            scheduleId: scheduleId,
            date: scheduleData['date'],
            day: scheduleData['day'],
            taskCount: (scheduleData['tasks'] as List<dynamic>).length,
          ));
        }
      });
      _pastSchedules = loadedSchedules.reversed.toList();
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }



  Future<void> fetchAndSetPastTaskList(String scheduleId) async {
    final url =
        '${Secrets.FIREBASE_URL}/schedules/$_userId/$scheduleId.json?auth=$_authToken';
    try {
      _pastTaskList.clear();
      final response = await http.get(Uri.parse(url));
      final loadedScheduleData =
          json.decode(response.body) as Map<String, dynamic>;
      int scheduleIndex = _pastSchedules
          .indexWhere((schedule) => schedule.scheduleId == scheduleId);
      GenericSchedule pastSchedule = _pastSchedules[scheduleIndex];
      List<Task> fetchedTaskList = [];
      loadedScheduleData['tasks'].toList().forEach((task) {
        fetchedTaskList.add(Task(
          id: task['id'],
          date: DateTime.parse(pastSchedule.date!),
          text: task['text'],
          startTime: task['startTime'],
          endTime: task['endTime'],
          startTimeInDouble: task['startTimeInDouble'],
          endTimeInDouble: task['endTimeInDouble'],
          duration: task['duration'],
          effortRating: task['effortRating'],
          isCompleted: task['isCompleted'],
        ));
      });
      fetchedTaskList.sort((taskA, taskB) =>
          taskA.startTimeInDouble!.compareTo(taskB.startTimeInDouble!));
      _pastTaskList = fetchedTaskList;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }



  void clearData() {
    _pastSchedules.clear();
    _pastTaskList.clear();
  }
}
