# NewCare

Arabic-first Flutter workspace for a nursing center, adapted for phones, tablets, desktop and square monitors.

## Run

```powershell
cd D:\Work\NewCare
flutter pub get
flutter gen-l10n
flutter run -d chrome
```

The app opens with illustrative local data. Manager preview password: `newcare-demo`.
The email field and password gate are UI previews; they are not production authentication.

## Implemented UI and local behavior

- Animated circular brand splash and centered manager sign-in.
- Date, Cairo time, local-save state and shift open/closed controls in the header.
- Nursing shared-device flow: select your card, start/join/end shifts and reconcile the drawer.
- One add-case dialog with inside/outside tabs; outside address is required and phone optional.
- Recent cases remain a horizontally scrollable table on small screens.
- Case history has styled Arabic card/table tabs; wide screens show eight compact case cards per row.
- All UI typography uses Cairo Bold. Inside/outside and cash/wallet have distinct labeled color badges.
- Nursing can add cases, expenses and advances. Wallet payments never alter drawer cash.
- Manager transaction ledger combines source payments and cash movements without duplicate entries.
- Date-range, search, type, payment and nursing filters update the ledger totals and chart.
- Adjacent edit/delete icons open dialogs; changes require a reason and retain audit snapshots.
- Manager additions open dialogs. Nursing profiles include phone, monthly salary and manager identity.
- Procedures require an Arabic name and price only; supplies require an Arabic name.
- Payroll has salary and advance buttons, a salary register and advance chart.
- Managers can record nursing awards as cash outgoings. Salary changes and advances have no reason field; audit descriptions are generated automatically.
- Two visible access levels: nursing and manager. Managers may also work as nursing staff.
- Arabic RTL / English LTR, local Cairo fonts, reusable cards, tables, fields, dialogs and navigation.

## Structure

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

This phase is a working UI and local preview. Shared preferences persist sample records, but are not a production clinical database. Supabase Auth, database/RLS enforcement, multiple real manager accounts, encrypted offline storage, synchronization and conflict resolution remain backend work. No Supabase credentials or cloud project were configured. The visible save indicator means saved on this device; audit queue entries have not been uploaded.

Monthly salary is a stored base amount. The displayed remaining amount subtracts advances in the selected date period. Awards are already-paid cash outgoings and appear separately, so they are not added again to the salary balance. Salary payment receipts, attendance-based calculation, proration and payroll settlement are not implemented. Recording a cash advance or award requires an open shift.

Deleting nursing or procedures archives them to preserve historical attribution; archiving shifts preserves linked cases. Removing cases or cash movements recalculates current totals and stores the previous record in the local audit log.

## Design and repository

Figma: https://www.figma.com/design/OEygfKSLA6bHRDFb1cmVBE/NewCare
GitHub: https://github.com/Desha29/NewCare

The existing local `main` tracks `origin/main`. No assistant-generated commits were created. Current UI changes are intentionally left in the working tree for the user to commit.
