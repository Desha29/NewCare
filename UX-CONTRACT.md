# NewCare frontend contracts

Business sources: `AGENTS.md`, the approved inventory/laboratory spec in `docs/superpowers/specs/`, and `docs/architecture.md`. Current user decisions: Windows cloud release begins with empty first-manager setup; only the paper catalogue names are preloaded; inventory starts at zero.

| Capability | Canonical owner | Contract | Evidence |
|---|---|---|---|
| Form | NcField + Flutter Form | App-owned required-field validation; localized labels; preserve values on failure; masked passwords with reveal | startup_layout_test, manager_login_integration_test |
| Select/Listbox | NcSelect | Flutter Material authored select, expands to available width, locale follows app | all_routes_test |
| Date | shared date filters + CenterClock | Localized calendar dates; Cairo timestamps; operational day starts 08:00 | operational_day_test, case_book_locations_test |
| Scrollbar | Flutter Material ScrollBehavior | Native Flutter scrollables; authentication has one page scroller and no fixed-height form | startup_layout_test, all_routes_test |
| Toast | NcToast / ToastificationWrapper | Success acknowledgment; inline persistent errors retain recovery context | transaction_ui_test |
| CRUD | Feature Cubits + WorkspaceRepository | Persist locally before success, journal atomically, retry exact IDs, protect manager actions | workspace_journal_test, production_workflow_sync_test |

Authentication startup needs no AppCubit provider. A busy submit disables all submit/mode actions. Existing-account mode stays on the same centered surface. Account selection chooses a username only; it never grants privileges. A prior verified manager can authenticate offline for the documented bounded cache period; account changes require online authorization.

The header's online/offline state comes from cloud requests. "Matched" is reserved for an explicit comparison of canonical content hashes at the same committed revision with no pending local operations. Counts alone are insufficient. Local preview is labeled local-only.

Destructive developer reset is not exposed in cloud mode: resetting a local snapshot without resetting its server journal would resurrect records. Release preparation is a one-time operator action, never an app-startup erase.
