import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_preview/device_preview.dart';
import 'package:sentry/sentry.dart';

import 'app/bootstrap.dart';
import 'core/debug/newcare_bloc_observer.dart';
import 'core/observability/error_reporting.dart';

Future<void> main() async {
  if (!ErrorReporting.enabled) {
    _runNewCare();
    return;
  }
  await Sentry.init(
    (options) {
      options.dsn = ErrorReporting.dsn;
      options.environment = kReleaseMode ? 'production' : 'profile';
      const release = String.fromEnvironment('SENTRY_RELEASE');
      if (release.isNotEmpty) options.release = release;
      options.sendDefaultPii = false;
      options.maxBreadcrumbs = 0;
      options.beforeSend = ErrorReporting.sanitize;
    },
    appRunner: () {
      final presentFlutterError = FlutterError.onError;
      FlutterError.onError = (details) {
        ErrorReporting.capture(
          details.exception,
          details.stack ?? StackTrace.current,
        );
        presentFlutterError?.call(details);
      };
      final dispatcher = PlatformDispatcher.instance;
      final previousOnError = dispatcher.onError;
      dispatcher.onError = (error, stackTrace) {
        ErrorReporting.capture(error, stackTrace);
        return previousOnError?.call(error, stackTrace) ?? false;
      };
      _runNewCare();
    },
  );
}

void _runNewCare() {
  Bloc.observer = NewCareBlocObserver();
  if (kDebugMode) {
    DevicePreview.enable(enabled: true);
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  runApp(const AppBootstrap());
}
