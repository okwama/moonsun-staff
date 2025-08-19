import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:woosh_portal/providers/notice_provider.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.borderRadius = 20,
    this.buttonSize = 40,
    this.fillColor,
    this.iconColor,
    this.iconSize = 24,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double borderRadius;
  final double buttonSize;
  final Color? fillColor;
  final Color? iconColor;
  final double iconSize;
  final Consumer<NoticeProvider>? badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: fillColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: onPressed,
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).colorScheme.onSurface,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: 0,
            right: 0,
            child: badge!,
          ),
      ],
    );
  }
}
