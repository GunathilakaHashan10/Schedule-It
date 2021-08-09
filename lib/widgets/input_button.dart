import 'package:flutter/material.dart';

class InputButton extends StatelessWidget {
  final BoxConstraints constraints;
  final Icon icon;
  final Widget child;
  final Color color;
  final VoidCallback onPressHandler;

  const InputButton({
    Key? key,
    required this.constraints,
    required this.icon,
    required this.child,
    required this.onPressHandler,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: constraints.maxWidth * 0.6,
      margin: EdgeInsets.symmetric(vertical: 0.25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(flex: 2, child: icon),
          Flexible(
            flex: 6,
            child: MaterialButton(
              minWidth: constraints.maxWidth * 0.5,
              child: child,
              onPressed: onPressHandler,
              color: color,
              padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10), bottom: Radius.circular(10)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
