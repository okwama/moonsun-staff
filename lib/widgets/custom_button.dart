import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.width = double.infinity,
    this.height = 50,
    this.color,
    this.textColor,
    this.borderRadius = 12,
    this.elevation = 0,
    this.borderSide,
    this.padding = const EdgeInsets.all(8),
    this.iconPadding = EdgeInsets.zero,
    this.iconColor,
    this.fontWeight = FontWeight.w600,
    this.fontSize = 16,
  });

  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final double width;
  final double height;
  final Color? color;
  final Color? textColor;
  final double borderRadius;
  final double elevation;
  final BorderSide? borderSide;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry iconPadding;
  final Color? iconColor;
  final FontWeight fontWeight;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).primaryColor,
          foregroundColor: textColor ?? Colors.white,
          elevation: elevation,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: iconColor ?? textColor ?? Colors.white,
                size: 20,
              ),
              Padding(padding: iconPadding, child: const SizedBox(width: 8)),
            ],
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontWeight: fontWeight, fontSize: fontSize),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 