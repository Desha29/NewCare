# Windows Release preparation — 4 November 2026

## Approved starting state

- Empty first-manager setup: no existing user accounts, staff, patients/cases, receipts, laboratory orders, stock consumption, outgoings or drawer handovers.
- Preserve only the paper catalogue: 20 procedure names and 15 stock names. Prices from the photo are intentionally excluded. Stock is initialized to zero because actual quantities were not supplied.
- `private.catalogue_seed` holds the names; a new center receives a single catalogue journal operation in the same transaction as creation. The enrolled device pulls it into encrypted local SQLite. Retrying setup does not repeatedly replenish stock.
- Clearing is an operator preparation step, not code that executes on each startup. The next launch creates the local store and shows setup; future launches preserve records.
- Protected database key material remains in Windows secure storage. App database, device session, binding and cached manager verifiers were cleared with the old local database.

## Implementation checked

1. Cases inside/outside, manual totals, initial and later cash/wallet receipts, price corrections, deletion and outstanding balance.
2. Stock additions/usage, atomic multi-item deduction, usage deltas, exhausted/archived inventory and persistence failures.
3. Independent lab orders, fixed historical catalogue snapshots, later receipts and patient result delivery.
4. Center/person outgoings, advances, awards, cash income, salary metadata and multiple drawer custody handovers.
5. Cairo 08:00 day boundaries, daily cash/wallet counters and separate carried physical cash.
6. Durable encrypted SQLite journal, restart, upload retries, lost acknowledgements, multi-page pull, concurrent local writes, and full restore into a second SQLite store.
7. Username manager authentication, manager creation, profile/password updates, bounded offline verification, manager-directory labels, separate device identity and denied unenrolled access.
8. Startup form required-field validation, recoverable server errors, stable busy actions and Arabic/English narrow/square/desktop layouts.

The live Supabase integration uses random disposable accounts and synthetic clinical
data. It verifies actual upload and full restore, catalogue download and contents,
duplicate-ID handling, unauthorized reads and canonical-hash reconciliation. Its
accounts and records are removed after testing; it requires an explicit opt-in and
is skipped in the normal suite.

## Final review corrections

- Auth request deadlines apply at the HTTP transport boundary. The serialized login
  operation is not abandoned while it can still mutate the shared manager session.
- Existing-center restoration precedes the manager staff projection, preserving
  salary and contact fields.
- Pull rejects an unenrolled/revoked device explicitly instead of returning a false
  successful empty result.
- Removed startup heuristics that guessed real records were disposable demo data.

## Evidence and limits

Project tests are authoritative for tested behavior; see the final command results
reported with delivery. UI captures are in the Codex task's `outputs` directory.
`premium-audit.json` records the static interface contract audit. No Git commits or
pushes are created by this work.

The cloud adapter supports the agreed single shared Windows device. It replicates
the operational journal; it does not implement multiwriter stock/payment conflict
arbitration. Offline manager verification requires an earlier successful online
login on the same device and expires after seven days. Local preferences used by web
previews are not the supported production data store. Tests exercise SQLite restart
and failure paths, not an actual physical power cut or loss of the Windows account.
Payroll settlement, attendance/proration and signed installer/SmartScreen reputation
remain outside this increment.
