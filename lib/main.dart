import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';

import 'app/bootstrap.dart';

void main() {
  if (kDebugMode) {
    DevicePreview.enable(enabled: true);
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  runApp(const AppBootstrap());
}
