import 'package:flutter/material.dart';

import '../helpers/helper.dart';
import '../providers/task.dart';
import 'task_overview_detail.dart';

class TaskOverview extends StatefulWidget {
  final Task task;
  final Color color;

  const TaskOverview({Key? key, required this.task, required this.color}) : super(key: key);

  @override
  _TaskOverviewState createState() => _TaskOverviewState();
}

class _TaskOverviewState extends State<TaskOverview>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller =
      AnimationController(vsync: this, duration: Duration(milliseconds: 150));
  late final Animation<double> scaleAnimation =
      CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: FittedBox(
        child: AlertDialog(
          contentPadding: EdgeInsets.all(10.0),
          titlePadding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
          title: Container(
            constraints: BoxConstraints(maxWidth: 150),
            child: Text(widget.task.text,
                maxLines: 4,
                softWrap: true,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                  fontSize: 14,
                )),
          ),
          content: Container(
            constraints: BoxConstraints(minHeight: 150, maxHeight: 150),
            child: Column(
              children: [
                TaskOverviewDetail(
                  label: 'Start time',
                  value: Helper.convert24hrTimeToLocalizeTime(widget.task.startTime),
                  color: widget.color,
                ),
                TaskOverviewDetail(
                  label: 'End time',
                  value: Helper.convert24hrTimeToLocalizeTime(widget.task.endTime),
                  color: widget.color,
                ),
                TaskOverviewDetail(
                  label: 'Completed',
                  value: widget.task.isCompleted.toString(),
                  color: widget.color,
                ),
                TaskOverviewDetail(
                  label: 'Effort Rating',
                  value: widget.task.effortRating.toString(),
                  color: widget.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
