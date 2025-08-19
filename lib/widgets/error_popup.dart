import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ErrorType {
  network,
  authentication,
  validation,
  server,
  permission,
  unknown,
}

class ErrorPopup extends StatelessWidget {
  final String title;
  final String message;
  final ErrorType type;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final String? actionText;

  const ErrorPopup({
    super.key,
    required this.title,
    required this.message,
    this.type = ErrorType.unknown,
    this.onRetry,
    this.onDismiss,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _getErrorColor(context).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getErrorColor(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getErrorIcon(),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: GoogleFonts.interTight(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Message
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  if (onDismiss != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onDismiss,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Text(
                          'Dismiss',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    if (onRetry != null) const SizedBox(width: 12),
                  ],
                  if (onRetry != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getErrorColor(context),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          actionText ?? 'Retry',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getErrorColor(BuildContext context) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.authentication:
        return Colors.red;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.server:
        return Colors.purple;
      case ErrorType.permission:
        return Colors.blue;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }

  IconData _getErrorIcon() {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.authentication:
        return Icons.lock_rounded;
      case ErrorType.validation:
        return Icons.warning_rounded;
      case ErrorType.server:
        return Icons.error_outline_rounded;
      case ErrorType.permission:
        return Icons.block_rounded;
      case ErrorType.unknown:
        return Icons.help_outline_rounded;
    }
  }
}
