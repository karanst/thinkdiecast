
import 'dart:async';
import 'dart:io';

/// Base class for all custom app-level exceptions.
/// Using typed exceptions instead of a bare `Exception` lets the UI layer
/// show the RIGHT message instead of a generic/garbled one.
abstract class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

/// No internet, DNS failure, timeout, connection refused, etc.
class NetworkException extends AppException {
  NetworkException([
    String message =
    'Network error. Please check your internet connection and try again.',
  ]) : super(message);
}

/// 401 — bad credentials or expired/invalid token.
class UnauthorizedException extends AppException {
  UnauthorizedException([
    String message = 'Invalid email or password.',
  ]) : super(message);
}

/// 400 / 422 — e.g. "email already registered", bad payload, etc.
class ValidationException extends AppException {
  ValidationException(super.message);
}

/// Fallback — 5xx, malformed response, or anything unrecognized.
class ServerException extends AppException {
  ServerException([
    String message = 'Something went wrong. Please try again later.',
  ]) : super(message);
}

/// Single source of truth for turning ANY caught error into a typed,
/// user-friendly [AppException]. Every catch block in the app should
/// funnel through this instead of hand-rolling `Exception('... $e')`,
/// which is what was causing the garbled "network error: unauthorised"
/// message before (errors were being wrapped 2-3 times).
AppException classifyError(Object error) {
  if (error is AppException) return error;

  final raw = error.toString();
  final lower = raw.toLowerCase();

  // --- Network-level failures --------------------------------------
  if (error is SocketException ||
      error is TimeoutException ||
      lower.contains('socketexception') ||
      lower.contains('timeoutexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('connection refused') ||
      lower.contains('connection reset') ||
      lower.contains('connection closed') ||
      lower.contains('network is unreachable') ||
      lower.contains('no internet')) {
    return NetworkException();
  }

  // --- Auth failures --------------------------------------------------
  if (lower.contains('401') ||
      lower.contains('unauthorized') ||
      lower.contains('unauthorised') ||
      lower.contains('invalid credentials') ||
      lower.contains('invalid email or password') ||
      lower.contains('incorrect password')) {
    return UnauthorizedException();
  }

  // --- Validation-ish failures -----------------------------------------
  if (lower.contains('400') ||
      lower.contains('422') ||
      lower.contains('already exists') ||
      lower.contains('duplicate') ||
      lower.contains('already registered')) {
    return ValidationException(_clean(raw));
  }

  // --- Everything else --------------------------------------------------
  final cleaned = _clean(raw);
  return cleaned.isEmpty ? ServerException() : ServerException(cleaned);
}

String _clean(String raw) {
  return raw
      .replaceAll('Exception: ', '')
      .replaceAll('Login failed: ', '')
      .replaceAll('Registration failed: ', '')
      .replaceAll('Logout failed: ', '')
      .replaceAll('Server error (500): ', '')
      .replaceAll('Server error (500):', '')
      .trim();
}




/// Base class for all custom app-level exceptions.
/// Using typed exceptions instead of a bare `Exception` lets the UI layer
/// show the RIGHT message instead of a generic/garbled one.
