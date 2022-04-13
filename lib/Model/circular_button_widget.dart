import 'package:flutter/material.dart';

class CircularImageButton extends StatelessWidget {
  final Function()? onPressed;
  final Widget? child;
  final double? size;
  CircularImageButton({this.onPressed, this.child, @required this.size});
  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      shape: CircleBorder(),
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * size!,
        child: child,
        backgroundImage: AssetImage('assets/coin.png'),
      ),
    );
  }
}
