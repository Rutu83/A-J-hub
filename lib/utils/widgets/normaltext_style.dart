import 'package:flutter/material.dart';

Widget normalText({
  String? text,
  Color? color,
  double? size,
}) {
  return Text(
    text!,
    style: TextStyle(
      fontFamily: "quick_semi",
      fontSize: size,
      color: color,
    ),
  );
}

Widget headingText({
  String? text,
  Color? color,
  double? size,
}) {
  return Text(
    text!,
    style: TextStyle(
        fontFamily: "Oswald-VariableFont_wght",
        fontSize: size,
        height: 2.0,
        letterSpacing: .8,
        color: color,
        fontWeight: FontWeight.w600
    ),
  );
}