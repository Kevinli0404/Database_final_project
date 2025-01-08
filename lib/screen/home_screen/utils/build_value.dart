// 創建值方法，支持可選顏色

import 'package:flutter/material.dart';

Widget buildValue(String text, {Color color = Colors.black}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: color,
      ),
    ),
  );
}
