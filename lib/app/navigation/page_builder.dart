import 'package:flutter/material.dart';

import '../../features/shifts/presentation/screens/start_shift_screen.dart';
import '../../features/shifts/presentation/screens/active_shift_screen.dart';
import '../../features/shifts/presentation/screens/end_shift_screen.dart';
import '../../features/shifts/presentation/screens/join_shift_screen.dart';
import '../../features/shifts/presentation/screens/handover_screen.dart';
import '../../features/shifts/presentation/screens/manager_shifts_screen.dart';
import '../../features/cases/presentation/screens/case_form_screen.dart';
import '../../features/cases/presentation/screens/case_history_screen.dart';
import '../../features/cases/presentation/screens/case_details_screen.dart';
import '../../features/cases/presentation/screens/saved_screen.dart';
import '../../features/drawer/presentation/screens/drawer_screen.dart';
import '../../features/analytics/presentation/screens/overview_screen.dart';
import '../../features/analytics/presentation/screens/reports_screen.dart';
import '../../features/analytics/presentation/screens/date_range_screen.dart';
import '../../features/management/presentation/screens/payroll_screen.dart';
import '../../features/management/presentation/screens/nursing_screen.dart';
import '../../features/management/presentation/screens/catalogue_screen.dart';
import '../../features/management/presentation/screens/permissions_screen.dart';
import '../../features/management/presentation/screens/audit_screen.dart';
import '../../features/management/presentation/screens/manager_case_log_screen.dart';
import '../../features/auth/presentation/screens/manager_login_screen.dart';
import '../../features/setup/presentation/screens/setup_screen.dart';
import '../../features/setup/presentation/screens/setup_nursing_screen.dart';
import '../../features/setup/presentation/screens/setup_catalogue_screen.dart';
import '../../features/setup/presentation/screens/ready_screen.dart';
import 'app_page.dart';

Widget buildPage(AppPage page) => switch (page) {
  AppPage.startShift => const StartShiftScreen(),
  AppPage.activeShift => const ActiveShiftScreen(),
  AppPage.insideCase => const CaseFormScreen(outside: false),
  AppPage.outsideCase ||
  AppPage.validation => const CaseFormScreen(outside: true),
  AppPage.caseDetails => const CaseDetailsScreen(),
  AppPage.cashMovement => const DrawerScreen(),
  AppPage.endShift => const EndShiftScreen(),
  AppPage.handover => const HandoverScreen(),
  AppPage.matched => const HandoverScreen(matched: true),
  AppPage.offline => const ActiveShiftScreen(localQueue: true),
  AppPage.saved => const SavedScreen(),
  AppPage.shiftCases => const CaseHistoryScreen(),
  AppPage.joinShift => const JoinShiftScreen(),
  AppPage.overview => const OverviewScreen(),
  AppPage.shifts => const ManagerShiftsScreen(),
  AppPage.caseLog => const ManagerCaseLogScreen(),
  AppPage.payroll => const PayrollScreen(),
  AppPage.nursing => const NursingScreen(),
  AppPage.catalogue => const CatalogueScreen(),
  AppPage.permissions => const PermissionsScreen(),
  AppPage.login => const ManagerLoginScreen(),
  AppPage.setup => const SetupScreen(),
  AppPage.reports => const ReportsScreen(),
  AppPage.audit => const AuditScreen(),
  AppPage.dateRange => const DateRangeScreen(),
  AppPage.setupNursing => const SetupNursingScreen(),
  AppPage.setupCatalogue => const SetupCatalogueScreen(),
  AppPage.ready => const ReadyScreen(),
};
