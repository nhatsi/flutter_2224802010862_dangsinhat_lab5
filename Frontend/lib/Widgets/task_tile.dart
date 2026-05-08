// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:to_do/Widgets/colors.dart';

class TaskTile extends StatefulWidget {
  final String text;
  void Function()? onTap;

  TaskTile({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isChecked ? green.withOpacity(0.45) : lightGrey,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            activeColor: green,
            checkColor: white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            side: const BorderSide(
              color: primaryColor,
              width: 1.5,
            ),
            onChanged: (value) {
              setState(() {
                isChecked = value ?? false;
              });

              if (isChecked) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: green,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                    content: Text(
                      'Đã đánh dấu hoàn thành',
                      style: TextStyle(
                        color: white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }
            },
          ),

          const SizedBox(width: 6),

          Expanded(
            child: Text(
              widget.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
              style: TextStyle(
                color: isChecked ? grey : black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.35,
                decoration:
                    isChecked ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
          ),

          const SizedBox(width: 10),

          InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: red,
                size: 23,
              ),
            ),
          ),
        ],
      ),
    );
  }
}