/*
 * Webkul Software.
 * @package Mobikul Application Code.
 * @Category Mobikul
 * @author Webkul <support@webkul.com>
 * @Copyright (c) Webkul Software Private Limited (https://webkul.com)
 * @license https://store.webkul.com/license.html
 * @link https://store.webkul.com/license.html
 *
 *
 */

import 'package:dio/dio.dart';

class DioExceptions implements Exception {
  DioExceptions.fromDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with API server";
        break;
      case DioExceptionType.unknown:
        message = "Connection to API server failed due to internet connection";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout in connection with API server";
        break;
      case DioExceptionType.badResponse:
        message = _handleError(dioError.response?.statusCode ?? 400);
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      default:
        message = "Something went wrong";
        break;
    }
  }

  String? message;

  String _handleError(int status) {
    switch (status) {
      case 400:
        return 'Bad request';
      case 401:
      case 403:
        return "Unauthorized request";
      case 404:
        return "Not found";
      case 409:
        return "Error due to a conflict";
      case 408:
        return "Connection request timeout";
      case 500:
        return 'Internal server error';
      case 503:
        return "Service unavailable";
      default:
        return 'Oops something went wrong';
    }
  }

  @override
  String toString() => message ?? '';
}

class DioCustomError implements DioException {
  DioCustomError(String message, DioException error) {
    this.requestOptions = error.requestOptions;
    this.message = message;
    this.type = error.type;
    this.error = error.error;
    this.response = error.response;
  }

  setMessage(String message) {
    this.message = message;
  }

  @override
  String message = '';

  @override
  String toString() => message;

  @override
  var error;

  @override
  late RequestOptions requestOptions;

  @override
  Response? response;

  // @override
  // StackTrace? stackTrace;

  @override
  late DioExceptionType type;

  @override
  DioException copyWith({RequestOptions? requestOptions, Response? response, DioExceptionType? type, Object? error, StackTrace? stackTrace, String? message}) {
    throw UnimplementedError();
  }

  @override
  late StackTrace stackTrace;
  
  @override
  DioExceptionReadableStringBuilder? stringBuilder;
}
