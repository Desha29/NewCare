import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/widgets/nc_adaptive_table.dart';

void main() {
  testWidgets('desktop table fills its available card width', (tester) async {
    tester.view.physicalSize = const Size(1440, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 1000,
              child: NcAdaptiveTable(
                headers: const ['Date', 'Status', 'Cases', 'Expected cash'],
                rows: const [
                  ['28 Oct', 'Open', '12', '4150'],
                ],
                emptyLabel: 'Empty',
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(DataTable)).width, 1000);
    expect(tester.takeException(), isNull);
  });
}
