# Inventory, laboratory and operational day implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. No commits or pushes are authorized.

**Goal:** Deliver stock consumption, independent laboratory billing/result receipt, used-supply table columns and 08:00 Cairo drawer/wallet counters.

**Architecture:** Extend the existing feature-first data/presentation/Cubit structure and atomic WorkspaceRepository snapshot/outbox. Keep immutable name/price/quantity snapshots and one source for each receipt. A read model scopes day counters without changing physical custody cash.

**Tech Stack:** Flutter, flutter_bloc, existing encrypted SQLite/outbox, timezone, ARB localization. No new package required.

**Spec:** ../specs/2026-10-31-inventory-laboratory-operational-day-design.md

## Global constraints

- Preserve existing UI identity and dirty work; no entities/domain/usecases, shifts, procedure prices, service keys, Edge Functions or Git commits.
- Cash/wallet receipts are counted once. Receiving a result does not collect money.
- Keep unknown historical stock quantities unknown. Never replay old consumption.
- Local features must work durably offline; do not claim the pending operational cloud sync is implemented.
- Manager inventory/catalogue/corrections remain guarded; nursing remains name selection.

## Review focus

- Failed persistence must leave case, stock and money unchanged; cover in task 1/2.
- Editing an exhausted/archived historical usage must not double consume; cover task 1.
- Catalog price changes while a lab draft is open must reject stale prices; cover task 2.
- 08:00 boundaries and Cairo DST must preserve carried custody cash; cover task 3.
- Added supply column must not shift money colors, method badges or dates incorrectly; cover task 5.

### Task 1: Stock models and atomic consumption

Files: features/inventory/data/models/{stock_item,stock_movement,case_stock_usage}.dart;
data/services/stock_changes.dart; cases/data/models/case_record.dart;
workspace/data/models/workspace_snapshot.dart; workspace_repository.dart;
local_workspace_repository.dart; management/data/record_mutations.dart.

Interfaces: `saveStockItem(StockItem)`, `archiveStockItem(String)`;
`StockChanges.applyUsage(data, before, after) -> WorkspaceSnapshot`.

- [x] Write `test/inventory_workflow_test.dart`: 10−2=8; duplicate no second debit;
  insufficient multi-item usage rolls back all; price edit leaves stock unchanged;
  usage correction applies delta; delete case does not restock; legacy roundtrip.
- [x] Observe RED, implement immutable models/default JSON arrays and audited changes.
- [x] Run inventory tests GREEN including failed-store/retry coverage.

### Task 2: Laboratory records, receipts and result status

Files: features/laboratory/data/models/{lab_test,lab_order,lab_payment}.dart;
data/services/lab_changes.dart; workspace snapshot/repository contracts;
transactions/data/models/transaction_entry.dart; analytics/data/models/report_summary.dart;
management/{data/managed_record_kind.dart,data/record_mutations.dart,presentation/models/record_editor_specs.dart}.

Interfaces: `saveLabTest`, `archiveLabTest`, `addLabOrder(order, initialPayment:)`,
`addLabPayment`, `setLabReceived(orderId, staffId, received:, reason:)`;
snapshot `paidForLab` / `remainingForLab` / `labPayments`.

- [x] RED tests in laboratory_workflow_test: 300 total, 100 cash + 200 wallet;
  unpaid creates no receipt; no overpay; idempotent receipt/received; stale-price rejection;
  received≠paid; catalogue rename/price snapshots remain; persistence failure.
- [x] Implement validated, serialized commands and frozen lines. Add lab receipt
  source to financial read models and generic manager receipt correction.
- [x] Run repository/report/transaction tests GREEN; verify actual receipt dates.

### Task 3: Business-day cash/wallet and history

Files: core/utils/operational_day.dart;
drawer/data/models/operational_day_summary.dart;
drawer/presentation/cubit/operational_day_cubit.dart; app/newcare_app.dart;
drawer widgets drawer_balance_card.dart and operational_day_history.dart.

Interfaces: `OperationalDay.containing(DateTime)`, `contains(DateTime)`;
`OperationalDaySummary.forDay(snapshot, day)` with netCashMinor/walletMinor/handovers;
`OperationalDayCubit.refresh()` plus clock injection and cancellation.

- [x] RED tests for 07:59:59/08:00:00, DST, resume, receipt on a later day,
  multiple handovers, no reset money mutation, opening cash remains custody-only.
- [x] Implement day boundaries and timed/resume refresh. Keep drawerBalance as
  all-time physical expected cash, add lab cash, show daily counter + wallet beneath.
- [x] Verify handover stale baseline/method exclusions and day history GREEN.

### Task 4: Focused Cubits and manager/nursing screens

Files: inventory/presentation/{cubit/inventory_cubit.dart,screens/inventory_screen.dart,
widgets/stock_item_editor.dart,widgets/case_stock_picker.dart};
laboratory/presentation/{cubit/laboratory_cubit.dart,screens/laboratory_screen.dart,
widgets/lab_catalogue.dart,widgets/lab_test_editor.dart,widgets/lab_order_form.dart,
widgets/lab_order_table.dart,widgets/lab_payment_dialog.dart,widgets/lab_result_dialog.dart};
app navigation/newcare_app.dart; ARBs + localization mapping.

- [x] Create DESIGN.md / UX-CONTRACT.md documenting existing tokens and canonical controls.
- [x] Write widget tests for manager guards, independent nurse orders, payment vs
  receipt status, retry draft preservation and stock quantity entry.
- [x] Reuse NcField/NcSelect/NcButton/ManagementFormDialog/NcAdaptiveTable.
  Use direct row actions, search/pagination, field validation and busy guards.
- [x] Translate all text, regenerate l10n and run widget/localization tests GREEN.

### Task 5: Case forms, ledgers, details and shared finance UI

Files: cases/presentation/models/case_draft.dart; widgets/case_form_fields.dart,
screens/case_form_screen.dart,widgets/case_ledger_section.dart;
screens/case_details_screen.dart; case_history_screen.dart; shared supply formatter;
analytics/transaction UI and diagnostic counts.

- [x] RED tests for inside/outside form consumption, both ledger columns,
  historical name-only usage and correct money/method/date columns after insertion.
- [x] Wire stock picker/draft; display usage in all case tables and details.
  Update financial kind labels, filters, reports/charts and exports for lab receipts.
- [x] Verify small/square/wide layouts, AR/EN and preserved drafts GREEN.

### Task 6: Acceptance and final review

- [x] Run formatter, flutter analyze, flutter test and flutter build web.
- [x] Capture and inspect stock/lab/day screens at desktop/mobile/tablet sizes.
- [x] Execute frontend premium static audit; distinguish Flutter applicability.
- [x] One fresh-context whole-change review (per executing-plans); repair Important
  findings with RED→GREEN tests, no second review dispatch.
- [x] Update implementation ledger and integration schema plan with actual evidence,
  current local-only sync boundary and Windows toolchain limitations.

## Execution ledger

Approved design and direct implementation instruction received. Execute inline;
do not ask for a second plan approval. This follows the user's explicit start
instruction and preserves the session's no-commit preference.
