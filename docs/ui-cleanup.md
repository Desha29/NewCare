# UI source cleanup — 2026-10-30

This pass removes unused source code and dependencies before backend integration. It does not change the current UI, navigation, record calculations or stored data format.

## Removed

- The six obsolete shift screens: active, start, join, end, handover and manager shifts.
- The three obsolete shift widgets: nursing grid, recent cases table and shift details dialog.
- The unused shift header controls and ShiftCubit, including its root provider.
- Empty directories left by the obsolete shift feature.
- Five unreferenced direct dependencies: equatable, lucide_icons_flutter, skeletonizer, shimmer and bloc_test. The lockfile was regenerated.

Eleven Dart files were removed. The source import graph now contains 131 Dart files, all reachable from `lib/main.dart`; no orphan Dart file remains in that graph.

## Retained deliberately

- Historical ShiftRecord data moved to `lib/features/workspace/data/models/legacy/shift_record.dart`. Its class and JSON fields are unchanged. Existing drawer adjustments, reports, stored records and compatibility tests still depend on it.
- Supply snapshots and old route aliases remain where current records or routing use them. They do not restore obsolete UI controls.
- Shared widgets, setup flows, manager editing dialogs, localization, live drawer totals, local preview data and Device Preview remain dependencies of the current interface.
- Platform folders, branding source assets, fonts, build configuration, tests, documentation and developer tools remain useful project inputs. Generated caches and build output remain ignored by Git.
- cupertino_icons remains because the Flutter release compiler identified framework IconData references to its font; removing it produced a missing-font warning. This preserves platform icon compatibility even without a direct application import.

## Verification

- `flutter analyze`: no issues.
- `flutter test`: all 74 tests passed, including stored-record compatibility and financial behavior.
- 28 fresh UI captures rendered successfully before and after cleanup. Pixel comparisons are identical below the first 88 pixels; that top strip contains the changing live date/time header. Header source and styling were not modified.
- `flutter build web --release --no-web-resources-cdn`: succeeded with no missing-font warning.

No commits were created. Supabase/database integration and production business rules have not been started by this cleanup.
