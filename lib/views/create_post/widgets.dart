import 'package:flutter/material.dart';

Widget tagWidget(String tag, VoidCallback removeTag) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    margin: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.grey.shade300,
      borderRadius: BorderRadius.circular(32),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          tag,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(
          width: 4,
        ),
        InkWell(
          onTap: () {
            removeTag.call();
          },
          child: const Icon(
            Icons.close,
            size: 14,
          ),
        )
      ],
    ),
  );
}
