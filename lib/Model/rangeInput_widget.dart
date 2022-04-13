import 'package:flutter/material.dart';
import 'package:wordPiggyBank/Model/const.dart';

class RangeInput extends StatelessWidget {
  final String? label;
  final String? error;
  final Function(String)? onChange;
  RangeInput({this.label, this.error, this.onChange});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        labelStyle: TextStyle(color: wordColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      )),
      child: Container(
        width: 100.0,
        child: TextField(
          textAlign: TextAlign.center,
          autofocus: true,
          onChanged: onChange,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: label,
              errorText: error //_inputIsValid ? '1~${_max - 1}' : null,
              ),
        ),
      ),
    );
  }
}
