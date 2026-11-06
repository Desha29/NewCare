import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry/sentry.dart';

abstract final class ErrorReporting {
  static const dsn = String.fromEnvironment('SENTRY_DSN');
  static const enabled = !kDebugMode && dsn != '';

  static void capture(Object error, StackTrace stackTrace) {
    if (enabled) {
      unawaited(Sentry.captureException(error, stackTrace: stackTrace));
    }
  }

  static final _sourcePath = RegExp(
    r'^(?:(?:package:|dart:)[\w][\w./-]*|[\w-]+)\.dart$',
  );
  static final _symbol = RegExp(r'^[\w.<>()$ -]+$');

  /// Allow only diagnostic fields. Exception text and SDK context can contain
  /// patient data, request parameters, and paths from the local machine.
  static SentryEvent? sanitize(SentryEvent event, Hint hint) {
    final exceptions = event.exceptions;
    if (exceptions == null || exceptions.isEmpty) return null;
    return SentryEvent(
      eventId: event.eventId,
      timestamp: event.timestamp,
      platform: event.platform,
      release: event.release,
      dist: event.dist,
      environment: event.environment,
      level: event.level,
      exceptions: exceptions.map((exception) {
        final stack = exception.stackTrace;
        return SentryException(
          type: _allowed(exception.type, _symbol) ?? 'Error',
          value: 'NewCare application error',
          stackTrace: stack == null
              ? null
              : SentryStackTrace(
                  frames: stack.frames.map((frame) {
                    return SentryStackFrame(
                      fileName: _allowed(frame.fileName, _sourcePath),
                      function:
                          _allowed(frame.function, _symbol) ?? '<unknown>',
                      lineNo: frame.lineNo,
                      colNo: frame.colNo,
                      inApp: frame.inApp,
                    );
                  }).toList(),
                ),
        );
      }).toList(),
    );
  }

  static String? _allowed(String? value, RegExp pattern) =>
      value != null && pattern.hasMatch(value) ? value : null;
}
