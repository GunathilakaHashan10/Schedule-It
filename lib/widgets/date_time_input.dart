import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../helpers/helper.dart';
import '../widgets/input_button.dart';
import '../providers/schedule_provider.dart';
import '../providers/task.dart';

enum TimeType { StartTime, EndTime }

class DateTimeInput extends StatefulWidget {
  final Function setDateAndTime;
  final DateTime? date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final bool isEditing;
  final String? editingTaskId;

  DateTimeInput({
    required this.setDateAndTime,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isEditing,
    this.editingTaskId,
  });

  @override
  _DateTimeInputState createState() => _DateTimeInputState();
}

class _DateTimeInputState extends State<DateTimeInput> {
  late DateTime? _selfDate;
  late TimeOfDay? _selfStartTime;
  late TimeOfDay? _selfEndTime;
  late TimeOfDay? _retrievedStartTime;
  bool? _error = false;
  TimeType? _errorType;
  String? _errorMessage;
  bool _isInit = true;

  @override
  void initState() {
    _selfDate = widget.date;
    _selfStartTime = widget.startTime;
    _selfEndTime = widget.endTime;
    _retrievedStartTime = widget.startTime;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if(_isInit) {
      if (Helper.isDateTimeEqual(DateTime.now(), _selfDate!) &&
          !widget.isEditing) {
        final scheduleData =
            Provider.of<ScheduleProvider>(context, listen: false).taskList;
        if (scheduleData.isNotEmpty) {
          TimeOfDay startTimeForThisTask = Helper.convert24hrTimeToTimeOfDay(
              scheduleData[scheduleData.length - 1].endTime);
          setState(() {
            _selfStartTime = startTimeForThisTask;
            _retrievedStartTime = startTimeForThisTask;
          });
        }
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  bool _isSelectedTimeValid(TimeOfDay selectedTime) {
    final List<Task> taskList =
        Provider.of<ScheduleProvider>(context, listen: false).taskList;
    if (taskList.isNotEmpty) {
      if(widget.editingTaskId != null) {
        int index = taskList.indexWhere((task) => task.id == widget.editingTaskId);
        taskList.removeAt(index);
      }
      double selectedTimeInDouble = Helper.convertTimeToDouble(selectedTime);
      bool isSelectedTimeValid = true;
      for (var i = 0; i < taskList.length; i++) {
        if (taskList[i].startTimeInDouble! < selectedTimeInDouble &&
            taskList[i].endTimeInDouble! > selectedTimeInDouble) {
          isSelectedTimeValid = false;
          break;
        }
      }
      return isSelectedTimeValid;
    } else {
      return true;
    }
  }

  void _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _selfDate!,
      firstDate: DateTime(2020, 01),
      lastDate: DateTime(2025, 01),
      helpText: 'Select a date',
    );
    if (selectedDate != null) {
      if (!Helper.isDateTimeEqual(DateTime.now(), selectedDate)) {
        setState(() {
          _selfStartTime = null;
          _selfDate = selectedDate;
        });
      } else {
        setState(() {
          _selfStartTime = _retrievedStartTime;
          _selfDate = selectedDate;
        });
      }
    }
  }

  void _selectTime(TimeType timeType) async {
    var _currentTime;
    if (timeType == TimeType.StartTime) {
      _currentTime = _selfStartTime;
    } else {
      _currentTime = _selfEndTime;
    }
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _currentTime != null ? _currentTime : TimeOfDay.now(),
    );
    if (selectedTime != null) {
      if (timeType == TimeType.StartTime) {
        setState(() {
          _selfStartTime = selectedTime;
          _error = false;
          _errorType = null;
        });
      } else {
        setState(() {
          _selfEndTime = selectedTime;
          _error = false;
          _errorType = null;
        });
      }
    }
  }

  void _submitData() {
    if (_selfStartTime == null) {
      setState(() {
        _error = true;
        _errorMessage = 'Start time is required.';
        _errorType = TimeType.StartTime;
      });
      return;
    }
    if (_selfEndTime == null) {
      setState(() {
        _error = true;
        _errorMessage = 'End time is required.';
        _errorType = TimeType.EndTime;
      });
      return;
    }

    if (Helper.isDateTimeEqual(DateTime.now(), _selfDate!)) {
      if (!_isSelectedTimeValid(_selfStartTime!)) {
        setState(() {
          _error = true;
          _errorMessage = 'Invalid start time.';
          _errorType = TimeType.StartTime;
        });
        return;
      }

      if (!_isSelectedTimeValid(_selfEndTime!)) {
        setState(() {
          _error = true;
          _errorMessage = 'Invalid end time.';
          _errorType = TimeType.EndTime;
        });
        return;
      }
    }

    if (Helper.convertTimeToDouble(_selfStartTime!) >= Helper.convertTimeToDouble(_selfEndTime!)) {
      setState(() {
        _error = true;
        _errorMessage = 'Start time must be less than end.';
      });
      return;
    }
    widget.setDateAndTime(
      newDate: _selfDate,
      startTime: _selfStartTime,
      endTime: _selfEndTime,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) => AlertDialog(
        content: FittedBox(
          fit: BoxFit.contain,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InputButton(
                  constraints: constraints,
                  icon: Icon(Icons.date_range),
                  child: Text(
                    Helper.isDateTimeEqual(DateTime.now(), _selfDate!)
                        ? 'Today'
                        : DateFormat.yMMMd().format(_selfDate!),
                  ),
                  onPressHandler: widget.isEditing || !Helper.isDateTimeEqual(DateTime.now(), _selfDate!) ? (){} : _selectDate,
                  color: Color(0xFFECEFF1),
                ),
                InputButton(
                  constraints: constraints,
                  icon: Icon(Icons.access_time),
                  child: Text(_selfStartTime != null
                      ? _selfStartTime!.format(context)
                      : 'Start time'),
                  onPressHandler: () => _selectTime(TimeType.StartTime),
                  color: _error! && _errorType == TimeType.StartTime
                      ? Color(0xFFEF9A9A)
                      : Color(0xFFECEFF1),
                ),
                InputButton(
                  constraints: constraints,
                  icon: Icon(Icons.access_time),
                  child: Text(_selfEndTime != null
                      ? _selfEndTime!.format(context)
                      : 'End time'),
                  onPressHandler: () => _selectTime(TimeType.EndTime),
                  color: _error! && _errorType == TimeType.EndTime
                      ? Color(0xFFEF9A9A)
                      : Color(0xFFECEFF1),
                ),

                _error!
                    ? Text(
                        _errorMessage!,
                        style: TextStyle(color: Theme.of(context).errorColor, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      )
                    : SizedBox(),
              ],
            ),
        ),
        actions: [
          MaterialButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          MaterialButton(
            padding: EdgeInsets.zero,
            child: Text('Ok'),
            onPressed: _submitData,
          )
        ],
        ),
    );
  }
}
