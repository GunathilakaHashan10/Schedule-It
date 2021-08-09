import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../providers/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).accentColor,
        child: FittedBox(
          child: Text(
            task.isCompleted ? 'Done' : 'Not',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ),
      title: Text(task.text),
      onTap: () =>  Helper.showTaskOverviewDialog(context: context, task: task, color: Theme.of(context).accentColor),
    );
  }
}
