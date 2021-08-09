// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:schedule_app/models/http_exception.dart';
// import 'dart:convert';
//
// import '../helpers/secrets.dart';
// import '../helpers/helper.dart';
// import 'task.dart';
//
// class ScheduleProvider with ChangeNotifier {
//   List<Task> _taskList = [];
//   String? _scheduleId = '';
//   final String? _authToken;
//   final String? _userId;
//
//   ScheduleProvider(this._authToken, this._userId, this._scheduleId, this._taskList);
//
//   List<Task> get taskList {
//     _taskList.sort((taskA, taskB) =>
//         taskA.startTimeInDouble!.compareTo(taskB.startTimeInDouble!));
//     return [..._taskList];
//   }
//
//   String get scheduleId {
//     return _scheduleId!;
//   }
//
//   void setScheduleId(String id) {
//     _scheduleId = id;
//   }
//
//   Future<void> fetchAndSetTasksForADay(DateTime dateTime) async {
//     String day = DateFormat('yyyy-MM-dd').format(dateTime);
//     try {
//       final scheduleData = await _fetchSchedule(day);
//       if (scheduleData!.isEmpty) {
//         return;
//       }
//
//       // print('fetchAndSetTasks() called................');
//       final List<Task> loadedTaskList = [];
//       scheduleData.forEach((scheduleId, value) {
//         _scheduleId = scheduleId;
//         if (value['tasks'] != null) {
//           value['tasks'].forEach((task) {
//             loadedTaskList.add(
//               Task(
//                 id: task['id'],
//                 text: task['text'],
//                 startTime: task['startTime'],
//                 endTime: task['endTime'],
//                 duration: task['duration'],
//                 isCompleted: task['isCompleted'],
//                 date: DateTime.now(),
//                 startTimeInDouble: task['startTimeInDouble'],
//                 endTimeInDouble: task['endTimeInDouble'],
//                 effortRating: task['effortRating'],
//               ),
//             );
//           });
//         }
//       });
//       _taskList = loadedTaskList;
//       notifyListeners();
//     } catch (error) {
//       throw error;
//     }
//   }
//
//   Future<void> fetchAndSetTasks() async {
//     String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     try {
//       final scheduleData = await _fetchSchedule(today);
//       if (scheduleData!.isEmpty) {
//         return;
//       }
//
//       // print('fetchAndSetTasks() called................');
//       final List<Task> loadedTaskList = [];
//       scheduleData.forEach((scheduleId, value) {
//         _scheduleId = scheduleId;
//         if (value['tasks'] != null) {
//           value['tasks'].forEach((task) {
//             loadedTaskList.add(
//               Task(
//                 id: task['id'],
//                 text: task['text'],
//                 startTime: task['startTime'],
//                 endTime: task['endTime'],
//                 duration: task['duration'],
//                 isCompleted: task['isCompleted'],
//                 date: DateTime.now(),
//                 startTimeInDouble: task['startTimeInDouble'],
//                 endTimeInDouble: task['endTimeInDouble'],
//                 effortRating: task['effortRating'],
//               ),
//             );
//           });
//         }
//       });
//       _taskList = loadedTaskList;
//       notifyListeners();
//     } catch (error) {
//       throw error;
//     }
//   }
//
//   Future<Map<String, dynamic>?> _fetchSchedule(String date) async {
//     final url =
//         '${Secrets.FIREBASE_URL}/schedules/$_userId.json?auth=$_authToken&orderBy="date"&equalTo="$date"';
//     try {
//       final response = await http.get(Uri.parse(url));
//       final scheduleData = json.decode(response.body) as Map<String, dynamic>;
//       return scheduleData;
//     } catch (error) {
//       throw error;
//     }
//   }
//
//   Future<void> addTask(Task newTask) async {
//     try {
//       if (Helper.isToday(newTask.date)) {
//         if (_taskList.isEmpty && _scheduleId == '') {
//           _taskList.add(newTask);
//           notifyListeners();
//           final response =
//           await _createNewScheduleAndAddTask(newTask, _taskList);
//           setScheduleId(json.decode(response.body)['name']);
//         } else {
//           _taskList.add(newTask);
//           notifyListeners();
//           final response =
//           await _addTaskToExistingSchedule(newTask, _taskList, _scheduleId);
//         }
//       } else {
//         String date = DateFormat('yyyy-MM-dd').format(newTask.date);
//         final existingSchedule = await _fetchSchedule(date);
//         List<Task> _futureTaskList = [];
//         if (existingSchedule!.isEmpty) {
//           _futureTaskList.add(newTask);
//           final response =
//           await _createNewScheduleAndAddTask(newTask, _futureTaskList);
//         } else {
//           String _existingScheduleId = '';
//           List<Task> _existingScheduleTaskList = [];
//           existingSchedule.forEach((schId, value) {
//             _existingScheduleId = schId;
//             value['tasks'].forEach((task) {
//               _existingScheduleTaskList.add(
//                 Task(
//                   id: task['id'],
//                   text: task['text'],
//                   startTime: task['startTime'],
//                   endTime: task['endTime'],
//                   duration: task['duration'],
//                   isCompleted: task['isCompleted'],
//                   date: newTask.date,
//                   startTimeInDouble: task['startTimeInDouble'],
//                   endTimeInDouble: task['endTimeInDouble'],
//                   effortRating: task['effortRating'],
//                 ),
//               );
//             });
//           });
//           _futureTaskList = _existingScheduleTaskList;
//           _futureTaskList.add(newTask);
//           final response = await _addTaskToExistingSchedule(
//               newTask, _futureTaskList, _existingScheduleId);
//         }
//       }
//     } catch (error) {
//       throw error;
//     }
//   }
//
//   Future<dynamic> _createNewScheduleAndAddTask(
//       Task newTask, List<Task> taskList) async {
//     final url =
//         '${Secrets.FIREBASE_URL}/schedules/$_userId.json?auth=$_authToken';
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         body: json.encode({
//           'day': DateFormat('EEE').format(newTask.date),
//           'date': DateFormat('yyyy-MM-dd').format(newTask.date),
//           'tasks': taskList
//               .map((task) => {
//             'id': task.id,
//             'text': task.text,
//             'startTime': task.startTime,
//             'endTime': task.endTime,
//             'duration': task.duration,
//             'effortRating': task.effortRating,
//             'isCompleted': task.isCompleted,
//             'startTimeInDouble': task.startTimeInDouble,
//             'endTimeInDouble': task.endTimeInDouble,
//           })
//               .toList(),
//         }),
//       );
//       return response;
//     } catch (error) {
//       throw error;
//     }
//   }
//
//   Future<dynamic> _addTaskToExistingSchedule(
//       Task newTask, List<Task> taskList, String? scheduleId) async {
//     final url =
//         '${Secrets.FIREBASE_URL}/schedules/$_userId/$scheduleId.json?auth=$_authToken';
//     try {
//       final response = await http.patch(
//         Uri.parse(url),
//         body: json.encode({
//           'day': DateFormat('EEE').format(newTask.date),
//           'date': DateFormat('yyyy-MM-dd').format(newTask.date),
//           'tasks': taskList
//               .map((task) => {
//             'id': task.id,
//             'text': task.text,
//             'startTime': task.startTime,
//             'endTime': task.endTime,
//             'duration': task.duration,
//             'effortRating': task.effortRating,
//             'isCompleted': task.isCompleted,
//             'startTimeInDouble': task.startTimeInDouble,
//             'endTimeInDouble': task.endTimeInDouble,
//           })
//               .toList(),
//         }),
//       );
//     } catch (error) {
//       throw error;
//     }
//   }
//
//   Future<void> setIsCompletedAndEffortRating(
//       String taskId, bool isCompleted, double effortRating) async {
//     int taskIndex = _taskList.indexWhere((task) => task.id == taskId);
//     Task task = _taskList[taskIndex];
//     bool previousIsCompleted = task.isCompleted;
//     task.setIsCompletedAndEffortRating(isCompleted, effortRating);
//     final url =
//         '${Secrets.FIREBASE_URL}/schedules/$_userId/$_scheduleId/tasks/$taskIndex.json?auth=$_authToken';
//
//     try {
//       final response = await http.patch(
//         Uri.parse(url),
//         body: json.encode({
//           'id': task.id,
//           'text': task.text,
//           'startTime': task.startTime,
//           'endTime': task.endTime,
//           'duration': task.duration,
//           'effortRating': effortRating,
//           'isCompleted': isCompleted,
//           'startTimeInDouble': task.startTimeInDouble,
//           'endTimeInDouble': task.endTimeInDouble,
//         }),
//       );
//       if (response.statusCode >= 400) {
//         task.setIsCompletedAndEffortRating(previousIsCompleted, 1.0);
//         throw HttpException('Something went wrong, please try again shortly.');
//       }
//     } catch (error) {
//       throw error;
//     }
//   }
//
//   Future<void> editTask(Task editedTask) async {
//     int taskIndex = _taskList.indexWhere((task) => task.id == editedTask.id);
//     Task originalTask = _taskList[taskIndex];
//     final url =
//         '${Secrets.FIREBASE_URL}/schedules/$_userId/$_scheduleId/tasks/$taskIndex.json?auth=$_authToken';
//     try {
//       _taskList[taskIndex] = editedTask;
//       notifyListeners();
//       final response = await http.patch(
//         Uri.parse(url),
//         body: json.encode({
//           'id': editedTask.id,
//           'text': editedTask.text,
//           'startTime': editedTask.startTime,
//           'endTime': editedTask.endTime,
//           'duration': editedTask.duration,
//           'effortRating': editedTask.effortRating,
//           'isCompleted': editedTask.isCompleted,
//           'startTimeInDouble': editedTask.startTimeInDouble,
//           'endTimeInDouble': editedTask.endTimeInDouble,
//         }),
//       );
//       if (response.statusCode >= 400) {
//         _taskList[taskIndex] = originalTask;
//         notifyListeners();
//         throw HttpException('Something went wrong, fallback changes..');
//       }
//     } catch (error) {
//       throw error;
//     }
//   }
//
//   Future<void> deleteTask(String taskId) async {
//     int taskIndex = _taskList.indexWhere((task) => task.id == taskId);
//
//     Task? backupTask = _taskList[taskIndex];
//     _taskList.removeAt(taskIndex);
//     notifyListeners();
//     final url =
//         '${Secrets.FIREBASE_URL}/schedules/$_userId/$_scheduleId.json?auth=$_authToken';
//     try {
//       final response = await http.patch(Uri.parse(url),
//           body: json.encode({
//             'day': DateFormat('EEE').format(backupTask.date),
//             'date': DateFormat('yyyy-MM-dd').format(backupTask.date),
//             'tasks': taskList
//                 .map((task) => {
//               'id': task.id,
//               'text': task.text,
//               'startTime': task.startTime,
//               'endTime': task.endTime,
//               'duration': task.duration,
//               'effortRating': task.effortRating,
//               'isCompleted': task.isCompleted,
//               'startTimeInDouble': task.startTimeInDouble,
//               'endTimeInDouble': task.endTimeInDouble,
//             })
//                 .toList(),
//           }));
//       if (response.statusCode >= 400) {
//         _taskList.add(backupTask);
//         notifyListeners();
//         throw HttpException('Something went wrong, fallback changes..');
//       }
//       backupTask = null;
//     } catch (error) {
//       throw error;
//     }
//   }
//
//   void clearData() {
//     _taskList.clear();
//     _scheduleId = '';
//   }
//
// }
