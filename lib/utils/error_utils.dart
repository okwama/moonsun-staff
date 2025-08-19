import 'package:flutter/material.dart';
import '../widgets/error_popup.dart';
import '../services/error_handler.dart';

class ErrorUtils {
  static void showErrorPopup(
    BuildContext context, {
    required dynamic error,
    int? statusCode,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    // Log the full error details including stack trace
    debugPrint('=== ERROR POPUP ===');
    debugPrint('Error: $error');
    debugPrint('Status Code: $statusCode');
    debugPrint('Stack Trace: ${StackTrace.current}');
    debugPrint('==================');
    
    final errorType = ErrorHandler.categorizeError(error, statusCode);
    final errorMessage = ErrorHandler.getErrorMessage(error, statusCode);
    final title = ErrorHandler.getErrorTitle(errorType);
    final description =
        ErrorHandler.getErrorDescription(errorType, errorMessage);
    final actionText = ErrorHandler.getActionText(errorType);
    final shouldShowRetry = ErrorHandler.shouldShowRetry(errorType);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorPopup(
        title: title,
        message: description,
        type: errorType,
        onRetry: shouldShowRetry ? onRetry : null,
        onDismiss: onDismiss ?? () => Navigator.of(context).pop(),
        actionText: shouldShowRetry ? actionText : null,
      ),
    );
  }

  static void showNetworkError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    showErrorPopup(
      context,
      error: 'Network connection error',
      statusCode: 0,
      onRetry: onRetry,
    );
  }

  static void showAuthenticationError(
    BuildContext context, {
    VoidCallback? onLogin,
  }) {
    showErrorPopup(
      context,
      error: 'Authentication failed',
      statusCode: 401,
      onRetry: onLogin,
    );
  }

  static void showPermissionError(
    BuildContext context, {
    String? specificMessage,
  }) {
    showErrorPopup(
      context,
      error: specificMessage ?? 'Permission denied',
      statusCode: 403,
    );
  }

  static void showValidationError(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
  }) {
    showErrorPopup(
      context,
      error: message,
      statusCode: 400,
      onRetry: onRetry,
    );
  }

  static void showServerError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    showErrorPopup(
      context,
      error: 'Internal server error',
      statusCode: 500,
      onRetry: onRetry,
    );
  }

  static void showIPRestrictionError(
    BuildContext context, {
    VoidCallback? onContactAdmin,
  }) {
    showErrorPopup(
      context,
      error: 'Check-in not allowed from this IP address',
      statusCode: 403,
      onRetry: onContactAdmin,
    );
  }

  static void showDeviceApprovalError(
    BuildContext context, {
    required String message,
    VoidCallback? onContactAdmin,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.device_unknown,
          color: Colors.orange,
          size: 48,
        ),
        title: const Text(
          'Device Approval Required',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Please contact your administrator to approve this device for attendance.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (onContactAdmin != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onContactAdmin();
              },
              child: const Text('Contact Admin'),
            ),
        ],
      ),
    );
  }

  static void showFormatError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    showErrorPopup(
      context,
      error: 'Invalid data format received from server',
      statusCode: 0,
      onRetry: onRetry,
    );
  }
}
