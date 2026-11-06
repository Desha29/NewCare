import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_preview/device_preview.dart';

import 'app/bootstrap.dart';
import 'core/debug/newcare_bloc_observer.dart';

void main() {
  Bloc.observer = NewCareBlocObserver();
  if (kDebugMode) {
    DevicePreview.enable(enabled: true);
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  runApp(const AppBootstrap());
}
