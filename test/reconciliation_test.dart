import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/features/sync/data/models/reconciliation.dart';

void main() {
  Future<DataManifest> manifest(
    String name, {
    int revision = 4,
    String scope = 'center-1:manager',
  }) => DataManifest.create(
    scope: scope,
    revision: revision,
    data: {
      'cases': [
        {'id': 'case-1', 'name': name},
      ],
    },
    counts: {'cases': 1},
  );

  test('equal record counts with different contents never match', () async {
    expect(
      reconcile(
        configured: true,
        authenticated: true,
        online: true,
        pendingCount: 0,
        conflictCount: 0,
        local: await manifest('one'),
        remote: await manifest('two'),
      ),
      ReconciliationStatus.different,
    );
  });
  test(
    'pending, offline, unauthenticated and different revision cannot match',
    () async {
      final local = await manifest('same');
      for (final args in [
        (false, true, 0, 0),
        (true, false, 0, 0),
        (true, true, 1, 0),
        (true, true, 0, 1),
      ]) {
        expect(
          reconcile(
            configured: true,
            authenticated: args.$1,
            online: args.$2,
            pendingCount: args.$3,
            conflictCount: args.$4,
            local: local,
            remote: local,
          ),
          isNot(ReconciliationStatus.matched),
        );
      }
      expect(
        reconcile(
          configured: true,
          authenticated: true,
          online: true,
          pendingCount: 0,
          conflictCount: 0,
          local: local,
          remote: await manifest('same', revision: 5),
        ),
        ReconciliationStatus.different,
      );
      expect(
        reconcile(
          configured: true,
          authenticated: true,
          online: true,
          pendingCount: 0,
          conflictCount: 0,
          local: local,
          remote: await manifest('same', scope: 'other'),
        ),
        ReconciliationStatus.different,
      );
    },
  );
  test(
    'only verified identical content in the same scope and revision matches',
    () async {
      final local = await manifest('same');
      expect(
        reconcile(
          configured: true,
          authenticated: true,
          online: true,
          pendingCount: 0,
          conflictCount: 0,
          local: local,
          remote: await manifest('same'),
        ),
        ReconciliationStatus.matched,
      );
      expect(
        reconcile(
          configured: false,
          authenticated: true,
          online: true,
          pendingCount: 0,
          conflictCount: 0,
          local: local,
          remote: local,
        ),
        ReconciliationStatus.unconfigured,
      );
    },
  );
  test(
    'canonical hashes ignore record order but retain real content',
    () async {
      final a = await DataManifest.create(
        scope: 'x',
        revision: 1,
        counts: {},
        data: {
          'rows': [
            {'id': 'b', 'value': 2},
            {'id': 'a', 'value': 1},
          ],
        },
      );
      final b = await DataManifest.create(
        scope: 'x',
        revision: 1,
        counts: {},
        data: {
          'rows': [
            {'value': 1, 'id': 'a'},
            {'value': 2, 'id': 'b'},
          ],
        },
      );
      expect(a.contentHash, b.contentHash);
    },
  );
}
