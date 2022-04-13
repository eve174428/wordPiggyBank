import 'package:flutter/material.dart';

class RoundedGradientButton extends StatelessWidget {
  final Function()? onPressed;
  final IconData? icon;
  final String? buttonName;
  RoundedGradientButton(
      {@required this.onPressed,
      @required this.icon,
      @required this.buttonName});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      elevation: 2.0,
      child: Ink(
        padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xffCDAC4A),
                Color(0xffB28F39),
              ]),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey[800],
            ),
            Text(buttonName!),
          ],
        ),
      ),
    );
  }
}
