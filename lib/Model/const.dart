import 'package:flutter/material.dart';

const TextStyle wordBoldStyle =
    TextStyle(color: wordColor, fontWeight: FontWeight.bold);
const TextStyle boldFont = TextStyle(fontWeight: FontWeight.bold);
const Color mainColor = Color(0xffFEEC50);
const Color wordColor = Color(0xff6A360D);
const Color appbarColor = Color(0xffFDBE14);
const gradientBgImage = BoxDecoration(
  gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xffFDBE14), Color(0xffFEEC50)]),
  image: DecorationImage(
    image: AssetImage('assets/pig.png'),
    fit: BoxFit.cover,
  ),
);
