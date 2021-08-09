import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../helpers/helper.dart';
import '../models/http_exception.dart';
import '../providers/task.dart';
import '../providers/schedule_provider.dart';

class EffortRatingAlertDialog extends StatefulWidget {
  final BuildContext? ancestorContext;
  final Task? task;

  EffortRatingAlertDialog({Key? key, this.task, this.ancestorContext})
      : super(key: key);

  @override
  _EffortRatingAlertDialogState createState() =>
      _EffortRatingAlertDialogState();
}

class _EffortRatingAlertDialogState extends State<EffortRatingAlertDialog> with SingleTickerProviderStateMixin {
  double _effortRating = 1.0;
  late final AnimationController controller =
  AnimationController(vsync: this, duration: Duration(milliseconds: 150));
  late final Animation<double> scaleAnimation =
  CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
  bool _isSubmitting = false;

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
      child: AlertDialog(
        content: Container(
          constraints: BoxConstraints(
              minHeight: 120, maxHeight: 120, minWidth: 250, maxWidth: 250),
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isSubmitting
                  ? LinearProgressIndicator(
                color: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
                minHeight: 5,
              )
                  : SizedBox(),
              const Text(
                'Please mention your effort to complete this task',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: RatingBar.builder(
                  initialRating: 1,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 3.0),
                  itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.black87,
                      size: 1,
                    ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _effortRating = rating;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          MaterialButton(
            child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          MaterialButton(
            child: const Text('Done', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            onPressed: () async {
              setState(() {
                _isSubmitting = true;
              });
              try {
                await Provider.of<ScheduleProvider>(context, listen: false)
                    .setIsCompletedAndEffortRating(
                        widget.task!.id, true, _effortRating)
                    .then((value) {
                  Navigator.of(context).pop();
                });
              } on HttpException catch (error) {
                Helper.showSnackBar(widget.ancestorContext!, error.message,
                    Theme.of(widget.ancestorContext!).primaryColor);
                Navigator.of(context).pop();
              } catch (error) {
                const errorMessage =
                    "Something went wrong, please try again shortly.";
                Helper.showSnackBar(widget.ancestorContext!, errorMessage,
                    Theme.of(widget.ancestorContext!).primaryColor);
                setState(() {
                  _isSubmitting = false;
                });
                Navigator.of(context).pop();
              }
            },
          )
        ],
      ),
    );
  }
}
