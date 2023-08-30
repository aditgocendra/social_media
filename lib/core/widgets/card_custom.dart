import 'package:flutter/material.dart';

Widget cardCustom({required Widget content}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade300,
          offset: const Offset(0, 0),
          blurRadius: 1.6,
          spreadRadius: 0.8,
        )
      ],
    ),
    child: content,
  );
}
