import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schedule_app/models/http_exception.dart';
import 'package:uuid/uuid.dart';

import '../helpers/helper.dart';
import '../models/http_exception.dart';
import 'date_time_input.dart';
import '../providers/schedule_provider.dart';
import '../providers/task.dart';

class AddNewTask extends StatefulWidget {
  final bool isEditing;
  final Task? task;
  final DateTime date;

  const AddNewTask(
      {Key? key, required this.isEditing, this.task, required this.date})
      : super(key: key);

  @override
  _AddNewTaskState createState() => _AddNewTaskState();
}

class _AddNewTaskState extends State<AddNewTask> {
  final _newTaskController = TextEditingController();
  DateTime? _date = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _error = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    _date = widget.date;
    if (widget.isEditing) {
      _newTaskController..text = widget.task!.text;
      _startTime = Helper.convert24hrTimeToTimeOfDay(widget.task!.startTime);
      _endTime = Helper.convert24hrTimeToTimeOfDay(widget.task!.endTime);
    }
    super.initState();
  }

  @override
  void dispose() {
    _newTaskController.dispose();
    super.dispose();
  }

  void _setDateAndTime({
    DateTime? newDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    setState(() {
      _date = newDate;
      _startTime = startTime;
      _endTime = endTime;
    });
  }

  void _showDateTimeInput(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => DateTimeInput(
        setDateAndTime: _setDateAndTime,
        date: _date,
        startTime: _startTime,
        endTime: _endTime,
        isEditing: widget.isEditing,
        editingTaskId: widget.isEditing ? widget.task!.id : null,
      ),
    );
  }

  Future<void> _addTask() async {
    if (_newTaskController.text.isEmpty) {
      setState(() {
        _error = true;
      });
      return;
    }
    if (_startTime == null || _endTime == null) {
      _showDateTimeInput(context);
      return;
    }
    try {
      setState(() {
        _isSubmitting = true;
      });
      if (widget.isEditing) {
        final editedTask = Task(
          id: widget.task!.id,
          text: _newTaskController.text,
          date: _date!,
          startTime: Helper.convertTimeOfDayToString(_startTime!),
          endTime: Helper.convertTimeOfDayToString(_endTime!),
          duration: Helper.calculateDurationInSeconds(_startTime!, _endTime!),
          startTimeInDouble: Helper.convertTimeToDouble(_startTime!),
          endTimeInDouble: Helper.convertTimeToDouble(_endTime!),
          createdAt: widget.task!.createdAt,
          editedAt: DateTime.now().toIso8601String(),
        );
        await Provider.of<ScheduleProvider>(context, listen: false)
            .editTask(editedTask);
      } else {
        final newTask = Task(
          id: Uuid().v4(),
          text: _newTaskController.text,
          date: _date!,
          startTime: Helper.convertTimeOfDayToString(_startTime!),
          endTime: Helper.convertTimeOfDayToString(_endTime!),
          duration: Helper.calculateDurationInSeconds(_startTime!, _endTime!),
          startTimeInDouble: Helper.convertTimeToDouble(_startTime!),
          endTimeInDouble: Helper.convertTimeToDouble(_endTime!),
          createdAt: DateTime.now().toIso8601String(),
        );
        await Provider.of<ScheduleProvider>(context, listen: false)
            .addTask(newTask);
      }
    } on HttpException catch (error) {
      Helper.showSnackBar(
          context, error.message, Theme.of(context).primaryColor);
    } catch (error) {
      const errorMessage = 'Something went wrong. Please try again shortly.';
      Helper.showSnackBar(
          context, errorMessage, Theme.of(context).primaryColor);
    }
    setState(() {
      _isSubmitting = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (ctx, constraints) => Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                height: constraints.maxHeight * 0.2,
                width: constraints.maxWidth,
                constraints: BoxConstraints(maxHeight: 200, minHeight: 150),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _isSubmitting
                        ? LinearProgressIndicator(
                            color: Theme.of(context).primaryColor,
                            backgroundColor: Colors.white,
                            minHeight: 5,
                          )
                        : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: 'New task',
                            border: InputBorder.none,
                            errorText: _error ? 'New task is required.' : null,
                            contentPadding: EdgeInsets.all(10)),
                        controller: _newTaskController,
                        autofocus: true,
                        onSubmitted: (_) {},
                        onChanged: (_) {
                          if (_error) {
                            setState(() {
                              _error = false;
                            });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: Icon(Icons.date_range),
                                onPressed: () => _showDateTimeInput(context),
                              ),
                            ],
                          ),
                          MaterialButton(
                            child: Text('Save'),
                            onPressed: () {
                              _addTask();
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
  }
}
