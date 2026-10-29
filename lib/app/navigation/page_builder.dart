import '../../features/cases/presentation/screens/case_register_screen.dart';
import '../../features/cases/data/models/case_record.dart';
import '../../features/drawer/presentation/screens/manager_drawer_screen.dart';

import 'package:flutter/material.dart';

import '../../features/cases/presentation/screens/case_form_screen.dart';
import '../../features/cases/presentation/screens/case_book_screen.dart';
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
import '../../features/transactions/presentation/screens/transactions_screen.dart';

Widget buildPage(AppPage page, {double availableHeight = 0}) => switch (page) {
  AppPage.startShift => const CaseRegisterScreen(),
  AppPage.activeShift => CaseRegisterScreen(availableHeight: availableHeight),
  AppPage.insideCase => const CaseFormScreen(outside: false),
  AppPage.outsideCase ||
  AppPage.validation => const CaseFormScreen(outside: true),
  AppPage.caseDetails => const CaseDetailsScreen(),
  AppPage.cashMovement => const DrawerScreen(),
  AppPage.endShift => const CaseRegisterScreen(),
  AppPage.handover => const CaseRegisterScreen(),
  AppPage.matched => const CaseRegisterScreen(),
  AppPage.offline => const CaseRegisterScreen(),
  AppPage.saved => const SavedScreen(),
  AppPage.shiftCases => const CaseBookScreen(),
  AppPage.insideCaseBook => const CaseBookScreen(
    key: ValueKey(CaseLocation.inside),
  ),
  AppPage.outsideCaseBook => const CaseBookScreen(
    key: ValueKey(CaseLocation.outside),
    location: CaseLocation.outside,
  ),
  AppPage.joinShift => const CaseRegisterScreen(),
  AppPage.overview => const OverviewScreen(),
  AppPage.shifts => const ManagerDrawerScreen(),
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
  AppPage.transactions => const TransactionsScreen(),
};
