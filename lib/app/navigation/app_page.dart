enum AppPage {
  startShift,
  activeShift,
  insideCase,
  outsideCase,
  caseDetails,
  cashMovement,
  endShift,
  handover,
  offline,
  saved,
  shiftCases,
  joinShift,
  matched,
  validation,
  insideCaseBook,
  outsideCaseBook,
  overview,
  shifts,
  caseLog,
  payroll,
  nursing,
  catalogue,
  permissions,
  login,
  setup,
  reports,
  audit,
  dateRange,
  setupNursing,
  setupCatalogue,
  ready,
  transactions;

  bool get isManager => index >= AppPage.overview.index;
  bool get isCaseBook =>
      this == AppPage.shiftCases ||
      this == AppPage.insideCaseBook ||
      this == AppPage.outsideCaseBook;
  bool get needsManager =>
      isManager &&
      this != AppPage.login &&
      this != AppPage.setup &&
      this != AppPage.setupNursing &&
      this != AppPage.setupCatalogue &&
      this != AppPage.ready;
  String get labelKey => switch (this) {
    AppPage.activeShift ||
    AppPage.startShift ||
    AppPage.endShift ||
    AppPage.joinShift ||
    AppPage.handover ||
    AppPage.matched ||
    AppPage.offline => 'caseRegister',
    AppPage.shiftCases => 'caseBook',
    AppPage.insideCaseBook => 'inside',
    AppPage.outsideCaseBook => 'outside',
    AppPage.shifts => 'drawer',
    AppPage.nursing => 'nursing',
    _ => name,
  };
}
