enum AppPage {
  startShift, activeShift, insideCase, outsideCase, caseDetails, cashMovement,
  endShift, handover, offline, saved, shiftCases, joinShift, matched, validation,
  overview, shifts, caseLog, payroll, nursing, catalogue, permissions, login,
  setup, reports, audit, dateRange, setupNursing, setupCatalogue, ready;
  bool get isManager => index >= AppPage.overview.index;
  bool get needsManager => isManager && this != AppPage.login && this != AppPage.setup && this != AppPage.setupNursing && this != AppPage.setupCatalogue && this != AppPage.ready;
  String get labelKey => switch(this) { AppPage.nursing=>'nursing', _=>name };
}

