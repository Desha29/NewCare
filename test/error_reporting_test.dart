import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/observability/error_reporting.dart';
import 'package:sentry/sentry.dart';

void main() {
  test('error reports retain source locations without operational data', () {
    final event = SentryEvent(
      release: 'newcare@0.1.0+1',
      user: SentryUser(email: 'private@example.invalid'),
      request: SentryRequest(url: 'https://example.invalid/private-case'),
      breadcrumbs: [Breadcrumb(message: 'private breadcrumb')],
      exceptions: [
        SentryException(
          type: 'StateError',
          value: 'private patient name',
          stackTrace: SentryStackTrace(
            frames: [
              SentryStackFrame(
                fileName: 'package:newcare/main.dart',
                function: 'main',
                lineNo: 42,
                vars: {'patient': 'private patient name'},
              ),
              SentryStackFrame(
                fileName: '/home/private-user/app.dart',
                function: 'start',
              ),
            ],
          ),
        ),
      ],
    );

    final report = ErrorReporting.sanitize(event, Hint())!;
    final json = jsonEncode(report.toJson());
    expect(json, isNot(contains('private')));
    expect(json, contains('StateError'));
    expect(json, contains('package:newcare/main.dart'));
    expect(json, contains('newcare@0.1.0+1'));
    expect(report.exceptions!.single.stackTrace!.frames.first.lineNo, 42);
  });
}
