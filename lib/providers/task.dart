import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Task with ChangeNotifier {
  final String id;
  final String text;
  final DateTime date;
  final String startTime;
  final String endTime;
  double? startTimeInDouble;
  double? endTimeInDouble;
  bool isCompleted;
  double? duration;
  double? effortRating;
  String? createdAt;
  String? editedAt;

  Task({
    required this.id,
    required this.text,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.startTimeInDouble,
    this.endTimeInDouble,
    this.duration,
    this.isCompleted = false,
    this.effortRating = 1.0,
    this.createdAt,
    this.editedAt,
  });

  void setIsCompletedAndEffortRating(bool value, double effortRatingValue) {
    isCompleted = value;
    effortRating = effortRatingValue;
    notifyListeners();
  }




}
