import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/helper.dart';
import '../models/http_exception.dart';
import '../providers/task.dart';
import '../providers/schedule_provider.dart';
import '../widgets/effort_rating_alert_dialog.dart';

class ScheduleItem extends StatelessWidget {
  final BuildContext ancestorContext;

  ScheduleItem({required this.ancestorContext});

  void _showCompletedMarkerDialog(BuildContext context, Task task) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) =>
            EffortRatingAlertDialog(task: task, ancestorContext: context));
  }

  Future<void> _removeTask(BuildContext context, String taskId) async {
    try {
      await Provider.of<ScheduleProvider>(context, listen: false)
          .deleteTask(taskId);
    } on HttpException catch (error) {
      Helper.showSnackBar(
          context, error.message, Theme.of(context).primaryColor);
    } catch (error) {
      const errorMessage = 'Something went wrong, please try again shortly.';
      Helper.showSnackBar(
          context, errorMessage, Theme.of(context).primaryColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = Provider.of<Task>(context, listen: false);

    return Dismissible(
      key: ValueKey(task.id),
      background: Container(
        color: Theme.of(context).primaryColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 20,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to remove this task from the schedule?'),
            actions: [
              MaterialButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              MaterialButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => _removeTask(ancestorContext, task.id),
      child: GestureDetector(
        onLongPress: () => Helper.showAddNewTask(
          context: context,
          isEditing: true,
          task: task,
          date: task.date,
        ),
        onTap: () => Helper.showTaskOverviewDialog(
            context: context,
            task: task,
            color: Theme.of(context).primaryColor),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 1,
                  )),
              child: Text(
                Helper.convert24hrTimeToLocalizeTime(task.startTime),
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
            ),
            title: Text(
              task.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            trailing: Helper.isToday(task.date) ? Transform.scale(
              scale: 1.1,
              child: Consumer<Task>(
                builder: (ctx, taskItem, _) => Checkbox(
                  value: taskItem.isCompleted,
                  onChanged: (_) async {
                    if (taskItem.isCompleted) {
                      try {
                        await Provider.of<ScheduleProvider>(context,
                                listen: false)
                            .setIsCompletedAndEffortRating(task.id, false, 1);
                      } on HttpException catch (error) {
                        Helper.showSnackBar(context, error.message,
                            Theme.of(context).primaryColor);
                      } catch (error) {
                        var errorMessage =
                            'Something went wrong, please try again shortly.';
                        Helper.showSnackBar(context, errorMessage,
                            Theme.of(context).primaryColor);
                      }
                      return;
                    }
                    _showCompletedMarkerDialog(ancestorContext, task);
                  },
                  shape: CircleBorder(),
                  checkColor: Colors.white,
                  fillColor: MaterialStateProperty.resolveWith(
                    (_) {
                      return Theme.of(context).accentColor;
                    },
                  ),
                ),
              ),
            ) : const SizedBox(),
          ),
        ),
      ),
    );
  }
}
