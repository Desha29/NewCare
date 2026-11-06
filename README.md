<p align="center">
  <img src="assets/branding/newcare-logo.png" alt="NewCare Nursing Care Services" width="160">
</p>

# NewCare

An Arabic-first Flutter workspace for nursing centers. NewCare tracks cases, supplies, lab orders, payments, and drawer balances across phones, tablets, and desktop displays.

[Quick start](#run) · [Windows release](#verify-and-build) · [Error monitoring](#error-monitoring-with-sentry) · [Architecture](docs/architecture.md)

Windows release preparation and current verification: [4 November 2026](docs/release/2026-11-04-readiness.md). The cloud release opens first-manager setup on an unconfigured device. Only the approved 20 procedure names and 15 stock names are preloaded after setup; they have no prices and stock starts at zero.

Interface labels, hints, accessibility text and system messages are stored in Arabic and English ARB files. `localization_coverage_test.dart` checks referenced keys, enum labels, repository errors, ARB parity, exact runtime translations and hardcoded UI text. Route tests also reject the missing-translation fallback on rendered screens. User-entered names and notes remain record data.

## Run

```powershell
cd D:\Work\NewCare
flutter pub get
flutter gen-l10n
flutter run -d chrome
```

The app opens with an empty local workspace. The default local manager username is
`admin` and the initial password is `12345678`; change it during setup or from
manager settings. This local gate is separate from explicit cloud-auth mode.

To run with real Supabase authentication and synchronization, pass only the
public project values at launch:

```powershell
flutter run -d windows `
  --dart-define=NEWCARE_CLOUD=true `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co `
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_YOUR_PUBLIC_KEY
```

Apply every file in `supabase/migrations/` first, in filename order. The
identity foundation and username-account migrations are required before the
first manager setup; the workspace sync migration is required for operations
to synchronize. Do not put a service-role key in the Flutter app.

On Windows, the same values can be kept in the ignored local `.env` file.
Copy `.env.example` to `.env`, fill in the public Supabase values, and run:

```powershell
.\tool\run_windows.ps1
```

For the production Windows executable, build with the same cloud values:

```powershell
.\tool\build_windows_release.ps1
```

The executable is created under `build\windows\x64\runner\Release\`.
Release builds do not read `.env` after they are built; the script embeds the
values as compile-time `dart-define` settings.

The VS Code `NewCare · Windows` launch configuration uses
`config/local.json`, which is also ignored locally. Both files are local
configuration only and must never be committed.

## Error monitoring with Sentry

1. In your Sentry Flutter project, open **Settings → Projects → NewCare → Client Keys (DSN)**.
2. Add the client DSN as `SENTRY_DSN` in the local `.env` file. API auth tokens are for administrative tools and must stay outside the application and repository.
3. Build with `.\tool\build_windows_release.ps1`. To verify before distributing a release, run a profile build with `flutter run -d windows --profile --dart-define-from-file=.env` and check for a known test error under the **profile** environment in Sentry Issues.

When a DSN is set, profile and release builds report unhandled Dart and Flutter exceptions and unexpected startup and workspace-action failures. Reports keep exception types, source locations, and release metadata. The app excludes exception messages, request data, user context, breadcrumbs, screenshots, and native crash reports. Monitoring is inactive in debug builds and builds without a DSN.

The official Sentry plugin for Codex uses browser authorization to access Sentry projects and issues. The Flutter app only needs the project client DSN.

## Implemented UI and local behavior

- Direct case registration without opening, joining or closing shifts. Historical shift records remain readable in storage for migration compatibility.
- Two desktop columns for inside/outside cases, with prominent centered headings; small screens switch between the forms using tabs.
- Inline registration forms, searchable multiple procedure names and a manually entered case total. Procedures have no price field in the catalogue or selection UI. Inventory has names and integer quantities, with atomic deduction of quantities used in cases. Historical priced supply snapshots remain readable.
- Independent laboratory orders store patient name/age, frozen test names/prices, partial or full cash/wallet receipts, and result-delivery status. Delivering a result never creates income.
- Stock and lab catalogue rows use a red Delete action, not archive. Confirmation removes the catalogue row and synchronizes a deletion; previous case usage, stock movement history, laboratory orders and receipts keep their snapshots. Financial corrections remain possible after stock deletion.
- The drawer shows operational-day cash and wallet counters from 08:00 Cairo; the physical custody balance carries forward. Daily rollover does not erase history or withdraw money.
- Paid-at-registration amount, outstanding balance, subsequent cash/wallet receipts and a complete payment history. The outstanding-case filter searches all dates.
- Nursing can change a saved case price without changing existing receipts. Prices cannot fall below the amount already collected.
- Two outgoing categories: center outgoings and person outgoings. Person payments choose a purpose (advance, other payment or manager award) and a recipient (nursing staff or another person). Cash income stays separate. The UI has no standalone external-advance category.
- Drawer custody handover records sender, receiver, expected/count cash, difference and required mismatch notes. The next drawer holder receives the counted cash balance. Count differences stay separate from income and expenses.
- The large teal handover action sits below the outgoing card. The frontend excludes the sender from receiver choices, clears an invalid receiver when the sender changes and disables confirmation until two different people are selected. Login-based identity binding remains deferred.
- Financial reports and CSV include subsequent receipts by their actual payment dates. Wallet receipts do not increase physical drawer cash.
- Compact page headers without repeated logos, compact date/search controls, and dense readable case-book tables.
- Manager analytics, payroll, nursing cards, procedure catalogue, audit log, custom date ranges and direct edit/delete controls.
- Hero transitions for suitable record details, preserving source filters; reduced-motion settings are respected.
- Arabic RTL / English LTR, local Cairo Bold, reusable cards, tables, fields, dialogs and adaptive navigation.

The shared nursing device uses staff selection. Manager preview access is
separate from cloud-auth mode. In cloud mode, the first launch shows center
setup, then manager login, and the workspace starts synchronization after the
device is enrolled.

## Structure

```mermaid
flowchart TD
  UI[Adaptive screens and shared widgets] --> Cubit[Feature action Cubits]
  Cubit --> Contract[WorkspaceRepository]
  Contract --> Local[LocalWorkspaceRepository]
  Local --> Store[StringStore: protected Windows SQLite / web preview preferences]
  Local --> Stream[WorkspaceCubit snapshot stream]
  Stream --> UI
```

The workspace repository persists locally and the optional Supabase adapter
authenticates managers and synchronizes the protected operation journal after
the center device is enrolled. The diagram describes local case storage.

Details open on a real Navigator page route through `NcDetailPage`, with a unique `NcHeroTitle` per source record. Selection controls and editing dialogs keep their existing interactions. Tests cover forward/back navigation, retained filters, reduced motion and opening details from the actual feature screens.

```text
lib/
  app/                       bootstrap, navigation, app Cubit and adaptive shell
  core/                      theme, localization, clock, storage, shared widgets
  features/
    <feature>/
      data/models/           serializable records and derived read models
      data/repositories/     repository contracts and adapters where needed
      presentation/cubit/    state transitions
      presentation/screens/  screen composition
      presentation/widgets/  focused reusable feature components
  l10n/                      Arabic/English ARB and generated localization
```

There is no entity, domain or use-case layer. Cubits depend on repository contracts through constructor injection. Local repository writes are serialized, published after durable storage, and audited. Money uses integer minor units.

## Verify and build

```powershell
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn
flutter build apk --debug
```

Visual captures use the Flutter renderer without browser access:
`flutter test --update-goldens tools/capture_previews_test.dart`.
The capture tool writes previews to this task's outputs directory and is outside the normal test suite.

Android uses `kotlin.incremental=false` because the local package cache and checkout are on different Windows drives. Windows native builds need Visual Studio C++ tools; iOS/macOS builds require macOS.

## Data and backend boundary

Without the cloud launch defines, the app is local-only. With them and the
Supabase migrations applied, manager authentication and operation-journal
synchronization are enabled. The local journal remains the durable source until
the server acknowledges each operation. The supported model is one shared Windows
operational device per center. The server stores validated, center-scoped operation
envelopes; this is journal replication, not a normalized multiwriter clinical API.
Concurrent offline editing on multiple devices is not supported: stock and money
conflict arbitration require additional server-side business validation.

Monthly salary is a stored base amount. The displayed remaining amount subtracts advances in the selected date period. Awards are already-paid cash outgoings and appear separately, so they are not added again to the salary balance. Salary payment receipts, attendance-based calculation, proration and payroll settlement are not implemented. Cash movements and drawer custody transfers operate independently of shifts.

Deleting nursing or procedures archives them to preserve historical attribution. Historical shift data is retained for backward compatibility, with no shift controls in the operational UI. Removing cases or cash movements recalculates current totals and stores the previous record in the local audit log.

## Design and repository

The unused shift presentation feature and five unreferenced packages were removed without changing the current UI. Historical data compatibility stays under `workspace/data/models/legacy`. See [UI cleanup notes](docs/ui-cleanup.md) for the inventory and verification.

Figma: https://www.figma.com/design/OEygfKSLA6bHRDFb1cmVBE/NewCare
GitHub: https://github.com/Desha29/NewCare

The existing local `main` tracks `origin/main`. No assistant-generated commits were created. Current UI changes are intentionally left in the working tree for the user to commit.


## Accounting and troubleshooting

Case total is entered manually. Remaining balance equals the case total minus the initial receipt and subsequent receipts. A price correction cannot reduce the total below recorded receipts. Procedure selection supplies names only.

The physical drawer contains opening cash, cash case receipts, signed drawer movements and count differences from custody transfers. Wallet receipts stay outside physical cash. Drawer count differences are not income or expenses. See [architecture notes](docs/architecture.md).

Flutter web may report `Trying to render a disposed EngineFlutterView` during hot restart. This matches upstream reports [#175260](https://github.com/flutter/flutter/issues/175260) and [#182377](https://github.com/flutter/flutter/issues/182377). Refresh the browser tab; if necessary stop the development run and launch it again. No engine assertion is suppressed in this app.

If normal Git push fails in the Windows credential helper, the existing `tools/push-main.ps1` can publish user-created commits using the saved credential in memory. It never stages, creates commits or force pushes.

Outgoings use category helpers in records and transaction read models, so tables, search, charts and CSV share the same center/person classification. A generic person payment does not count as a nursing salary advance. Legacy advance records are displayed under person outgoings without rewriting their stored values.


## Preview devices and navigation

Run `flutter run -d chrome` in debug mode, then choose the devices icon in the workspace header. Device Preview 3 is installed through its binding before startup; a full restart is required after this integration. Its controls select phone, tablet, desktop or a 1024 × 1024 square monitor, simulate platform behavior, rotate, toggle the keyboard and change text scale. Reset returns to the real device. The package also supplies a Flutter DevTools extension. These controls and the preview binding are disabled in profile/release builds. Simulation checks layout; native platform builds still need testing on the corresponding devices.

The header menu hides/restores the sidebar on desktop and opens an explicitly closable drawer on phones. Case registration contains only the inside/outside forms; desktop cards fill the available page height and align their bottom actions. Short screens scroll without clipping fields. Draft form state survives responsive layout and sidebar changes. Compact forms pair amount fields and use available columns while preserving mobile touch targets.

The case book expands in the sidebar into Inside center and Outside center. Each destination shows only its own cases in one table using the full available content width. Phones and narrow tablet navigation also offer location chips. Date range, search, outstanding filters, details, price corrections and receipt collection remain available. The old case-book destination opens the inside ledger for compatibility.

Both case ledgers display the case's recorded payment method and its creation date/time in the center's timezone. Payment filtering combines with search, date range and outstanding balance. Outside cases show procedures alongside the address. Invoice, paid and outstanding columns use distinct colors; payment badges distinguish cash from wallet.

The drawer screen places outgoings on the right and live cash balance on the left in Arabic desktop layouts, with the custody handover button below the balance. On phones these sections stack. The balance is derived from workspace records and updates after cash case receipts, later cash receipts, outgoings and reconciliation adjustments. Wallet payments are excluded. The last count result is labeled separately from the current balance.

## Manager settings

Settings contains the manager profile, a password-change form and editable navigation names. Changing the preview password requires the current password, a matching confirmation and at least eight characters. A salted SHA-512 crypt hash is saved locally; the password itself is not stored. Once changed, the old preview password no longer unlocks the manager area and its hint is hidden. This is still a local preview gate, not production authentication.

Navigation names are saved per interface language and shared by sidebar, navigation rail, phone navigation and page header. Empty names use the translated default. Restore resets names for the current language; names are limited to 40 characters.


## Cloud authentication and local durability increment

See [implementation status, architecture and verification](docs/plans/2026-10-30-implementation-progress.md).
Windows uses encrypted SQLite payloads with a durable pending-operation journal.
The migration creates and verifies a protected backup before removing old
plaintext preference values. It never replaces unreadable data with an empty
workspace. Physical power-loss, installer preservation and portable key recovery
are separate acceptance gates, not claims made by the current tests.

The NewCare Supabase identity schema is deployed. Explicit cloud-auth mode adds
first manager setup, username/password login, manager creation and own-profile
editing. Contact email does not require confirmation and is separate from the
internal Auth identifier. Nursing staff continue to select a name without a login.
Manager offline login requires prior online verification on the same device and
expires after seven days; it does not issue a Supabase token.

```powershell
flutter run -d windows --dart-define-from-file=config/local.json
```

The local config is ignored by Git; `config/example.json` is the template. Only
publishable keys are accepted. Supabase must enable anonymous device sign-ins
and disable Confirm email for this username-only provisioning flow. Provisioning
refuses to send a confirmation message if that setting is still enabled.

Data diagnostics is locked inside the manager area. Explicit refresh replays the
cloud journal, compares canonical SHA-256 content hashes and the committed revision,
and checks the local pending queue before displaying "متطابقين". All operational
collections are included. Equal counts alone never prove a match.

The header shows cloud online/offline, active synchronization and pending operations,
including on narrow screens. Requests retry after local writes, app resume and every
30 seconds. A failed upload retains its exact operation ID; the server accepts an
identical retry and rejects a changed payload using that ID. The pull cursor advances
only after durable local application, and all 500-row pages are drained.

Manager login shows the enrolled center's manager names/usernames as selectable
cards. Directory labels are cached per center without emails, passwords or grants;
selecting one still requires password authentication. A new device must connect and
verify the manager online before offline login is available. Restoring an existing
center happens before projecting the manager into nursing staff, preserving salary
and phone data.

Release preparation clears the old test data once. The app never clears data on
ordinary startup, and it does not guess whether saved records are demonstration data.
Cloud mode does not expose the local-only reset button, which would otherwise allow
the server journal to restore deleted local records.
