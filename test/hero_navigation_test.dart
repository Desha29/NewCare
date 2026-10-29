import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/widgets/nc_detail_page.dart';

void main() {
  for (final reduced in [false, true]) {
    testWidgets(
      'record Hero returns to retained filters, reduced motion=$reduced',
      (tester) async {
        final search = TextEditingController(text: 'محمود');
        addTearDown(search.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: Scaffold(
                body: Builder(
                  builder: (context) => Column(
                    children: [
                      TextField(controller: search),
                      InkWell(
                        onTap: () => NcDetailPage.open(
                          context,
                          tag: 'record-1',
                          title: 'تركيب محلول',
                          child: const Text('record details'),
                        ),
                        child: const NcHeroTitle(
                          tag: 'record-1',
                          title: 'تركيب محلول',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.byType(InkWell));
        await tester.pumpAndSettle();
        final route = ModalRoute.of(tester.element(find.byType(NcDetailPage)));
        expect(
          route!.transitionDuration,
          reduced ? Duration.zero : const Duration(milliseconds: 260),
        );
        await tester.pumpAndSettle();
        expect(find.text('record details'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('محمود'), findsOneWidget);
        expect(find.byType(NcDetailPage), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
