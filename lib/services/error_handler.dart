import 'dart:convert';
import '../widgets/error_popup.dart';

class ErrorHandler {
  static ErrorType categorizeError(dynamic error, int? statusCode) {
    if (error is String) {
      // Handle string errors
      if (error.contains('Connection refused') ||
          error.contains('Network error') ||
          error.contains('SocketException')) {
        return ErrorType.network;
      }
      if (error.contains('Unauthorized') ||
          error.contains('Forbidden') ||
          error.contains('Token')) {
        return ErrorType.authentication;
      }
      if (error.contains('Validation failed') ||
          error.contains('Bad Request')) {
        return ErrorType.validation;
      }
      if (error.contains('Internal server error') || error.contains('500')) {
        return ErrorType.server;
      }
      if (error.contains('not allowed from this Network') ||
          error.contains('permission')) {
        return ErrorType.permission;
      }
    }

    // Handle status codes
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return ErrorType.validation;
        case 401:
        case 403:
          return ErrorType.authentication;
        case 404:
          return ErrorType.network;
        case 500:
          return ErrorType.server;
        default:
          return ErrorType.unknown;
      }
    }

    return ErrorType.unknown;
  }

  static Map<String, dynamic> parseErrorResponse(String responseBody) {
    try {
      return jsonDecode(responseBody);
    } catch (e) {
      return {
        'message': 'Unable to parse error response',
        'error': 'Parse Error',
        'statusCode': 0,
      };
    }
  }

  static String getErrorMessage(dynamic error, int? statusCode) {
    if (error is String) {
      // Try to parse JSON error response
      try {
        final errorData = jsonDecode(error);
        return errorData['message'] ?? error;
      } catch (e) {
        return error;
      }
    }

    return error.toString();
  }

  static String getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Connection Error';
      case ErrorType.authentication:
        return 'Authentication Error';
      case ErrorType.validation:
        return 'Validation Error';
      case ErrorType.server:
        return 'Server Error';
      case ErrorType.permission:
        return 'Permission Denied';
      case ErrorType.unknown:
        return 'Unknown Error';
    }
  }

  static String getErrorDescription(ErrorType type, String specificMessage) {
    switch (type) {
      case ErrorType.network:
        return 'Unable to connect to the server. Please check your internet connection and try again.';
      case ErrorType.authentication:
        return 'Your session may have expired. Please log in again.';
      case ErrorType.validation:
        return 'The data provided is invalid. Please check your input and try again.';
      case ErrorType.server:
        return 'The server encountered an error. Please try again later.';
      case ErrorType.permission:
        return 'You don\'t have permission to perform this action.';
      case ErrorType.unknown:
        return specificMessage.isNotEmpty
            ? specificMessage
            : 'An unexpected error occurred.';
    }
  }

  static String getActionText(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Retry';
      case ErrorType.authentication:
        return 'Login Again';
      case ErrorType.validation:
        return 'Fix & Retry';
      case ErrorType.server:
        return 'Try Again';
      case ErrorType.permission:
        return 'Contact Admin';
      case ErrorType.unknown:
        return 'Retry';
    }
  }

  static bool shouldShowRetry(ErrorType type) {
    switch (type) {
      case ErrorType.network:
      case ErrorType.server:
      case ErrorType.validation:
      case ErrorType.unknown:
        return true;
      case ErrorType.authentication:
      case ErrorType.permission:
        return false;
    }
  }

  static bool shouldAutoRetry(ErrorType type) {
    switch (type) {
      case ErrorType.network:
      case ErrorType.server:
        return true;
      case ErrorType.authentication:
      case ErrorType.validation:
      case ErrorType.permission:
      case ErrorType.unknown:
        return false;
    }
  }
}
