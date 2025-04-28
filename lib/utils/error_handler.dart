import 'dart:developer' as developer;

class AppException implements Exception {
  final String message;
  final String? details;
  final StackTrace? stackTrace;

  AppException(
    this.message, {
    this.details,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppException: $message${details != null ? ' - $details' : ''}';
  }
}

class ErrorHandler {
  static void handleError(dynamic error, {StackTrace? stackTrace}) {
    // Log error to console
    developer.log(
      'Error occurred',
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
    );

    // You could add additional error reporting mechanisms here
    // Such as Firebase Crashlytics, Sentry, etc.
  }

  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is TypeError) {
      return 'A type error occurred';
    }

    if (error is RangeError) {
      return 'A range error occurred';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  // Specific error types
  static AppException networkException(String message) {
    return AppException(
      'Network Error',
      details: message,
    );
  }

  static AppException authenticationException(String message) {
    return AppException(
      'Authentication Failed',
      details: message,
    );
  }

  static AppException validationException(String message) {
    return AppException(
      'Validation Error',
      details: message,
    );
  }
}
