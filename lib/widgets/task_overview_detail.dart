import 'package:flutter/material.dart';


class TaskOverviewDetail extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const TaskOverviewDetail({Key? key, required this.label, required this.value, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                    child: Text(':', style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      fontSize: 12,
                    ),),
                  )
                ],
              ),
            ),
          ),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Container(
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: color!,
                      width: 1,
                    )),
                child: Text(
                  value,
                  style: TextStyle(
                    color: color!,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                  ),
                ),
              ),
        ),
        ],
      ),
    );
  }
}
