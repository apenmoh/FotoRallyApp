import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor; // Now required
  final Color textColor; // Now required
  final double width;
  final double height;
  final double borderRadius;
  final double elevation;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
    required this.backgroundColor, // Marked as required, no default
    required this.textColor, // Marked as required, no default
    this.width = 0, // Default width
    this.height = 0, // Default height
    required this.borderRadius,
    this.elevation = 5.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: EdgeInsets.all(5.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: elevation,
        fixedSize: Size(width, height),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
