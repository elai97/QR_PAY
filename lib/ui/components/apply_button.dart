import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ApplyButton extends StatelessWidget {
  final String text;
  final Color? boderColor, backgroundColor, textColor;
  final Function press;
  const ApplyButton({
    Key? key,
    required this.text,
    required this.boderColor,
    required this.press,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.px,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: press as void Function()?,
        style: ElevatedButton.styleFrom(
          side: BorderSide(
            width: 1,
            color: boderColor!,
          ),
          backgroundColor: backgroundColor,
          elevation: 0.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.all(12),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
