// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NewCare';

  @override
  String get localPreview => 'Local preview · sample data';

  @override
  String get localSaved => 'Saved on this device';

  @override
  String get pendingSync => 'Cloud sync not configured';

  @override
  String get nursing => 'Nursing';

  @override
  String get manager => 'Manager';

  @override
  String get managerArea => 'Manager workspace';

  @override
  String get nurseArea => 'Nursing workspace';

  @override
  String get shift => 'Shift';

  @override
  String get cases => 'Cases';

  @override
  String get drawer => 'Cash drawer';

  @override
  String get settings => 'Settings';

  @override
  String get overview => 'Analytics overview';

  @override
  String get shifts => 'Shifts & drawer';

  @override
  String get caseLog => 'Case log';

  @override
  String get payroll => 'Payroll & advances';

  @override
  String get catalogue => 'Procedures';

  @override
  String get permissions => 'Settings';

  @override
  String get reports => 'Reports';

  @override
  String get audit => 'Audit & sync';

  @override
  String get startShift => 'Start a new shift';

  @override
  String get activeShift => 'Current shift';

  @override
  String get insideCase => 'Inside-center case';

  @override
  String get outsideCase => 'Outside-center case';

  @override
  String get caseDetails => 'Case details';

  @override
  String get cashMovement => 'Cash movement';

  @override
  String get endShift => 'End shift';

  @override
  String get handover => 'Receive shift';

  @override
  String get offline => 'Local operation queue';

  @override
  String get saved => 'Saved successfully';

  @override
  String get shiftCases => 'Shift cases';

  @override
  String get joinShift => 'Add nursing to shift';

  @override
  String get matched => 'Drawer reconciled';

  @override
  String get validation => 'Review visit details';

  @override
  String get login => 'Manager sign-in';

  @override
  String get setup => 'Set up NewCare';

  @override
  String get dateRange => 'Custom date range';

  @override
  String get setupNursing => 'Add nursing members';

  @override
  String get setupCatalogue => 'Procedures & opening cash';

  @override
  String get ready => 'Ready to start';

  @override
  String get save => 'Save';

  @override
  String get saveCase => 'Save case';

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get continueAction => 'Continue';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get all => 'All';

  @override
  String get inside => 'Inside center';

  @override
  String get outside => 'Outside center';

  @override
  String get cash => 'Cash';

  @override
  String get wallet => 'Wallet';

  @override
  String get amount => 'Amount paid';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get caseTitle => 'Case title';

  @override
  String get procedure => 'Procedure';

  @override
  String get supplies => 'Medical supplies';

  @override
  String get address => 'Visit address';

  @override
  String get phoneOptional => 'Phone · optional';

  @override
  String get caseOwner => 'Responsible nursing member';

  @override
  String get choose => 'Choose';

  @override
  String get requiredField => 'This field is required';

  @override
  String get addressRequired => 'An outside visit needs an address';

  @override
  String get invalidAmount => 'Enter a valid non-negative amount';

  @override
  String get noOpenShift => 'Start a shift before recording cases';

  @override
  String get shiftAlreadyOpen => 'A shift is already open';

  @override
  String get unknownStaff => 'Choose an active nursing member';

  @override
  String get staffNotInShift => 'This nursing member is not on the shift';

  @override
  String get reasonRequired => 'Explain the drawer difference';

  @override
  String get invalidProcedure => 'Choose a valid procedure';

  @override
  String get storageFailed => 'Could not save. Please try again';

  @override
  String get saveFailed => 'Could not complete the operation';

  @override
  String get memberName => 'Nursing member name';

  @override
  String get currentNursing => 'Nursing on this shift';

  @override
  String get lastCases => 'Latest shift cases';

  @override
  String get noCases => 'No cases recorded yet';

  @override
  String get newCase => 'Record another case';

  @override
  String get returnShift => 'Return to case registration';

  @override
  String get addInside => 'Add inside-center case';

  @override
  String get addOutside => 'Add home visit';

  @override
  String get chooseStarter => 'Who is starting this shift?';

  @override
  String get receiveDrawer => 'Continue to drawer handover';

  @override
  String get expectedCash => 'Expected cash';

  @override
  String get countedCash => 'Counted cash';

  @override
  String get difference => 'Drawer difference';

  @override
  String get differenceReason => 'Reason for difference';

  @override
  String get confirmHandover => 'Confirm receipt & start shift';

  @override
  String get varianceNote => 'The difference is recorded for manager review';

  @override
  String get balancedNote => 'Count matches expected cash';

  @override
  String get handoverNote =>
      'Only cash is counted; wallet payments are separate';

  @override
  String get finishNote =>
      'Confirm all home visits are recorded before closing';

  @override
  String get handoverNotes => 'Handover notes';

  @override
  String get finishShift => 'Close shift & prepare handover';

  @override
  String get staffBreakdown => 'Cases by nursing member';

  @override
  String get duration => 'Duration';

  @override
  String get openedAt => 'Started at';

  @override
  String get income => 'Cash received';

  @override
  String get expense => 'Outgoing';

  @override
  String get advance => 'Advance';

  @override
  String get movementKind => 'Movement type';

  @override
  String get reason => 'Reason';

  @override
  String get recordedBy => 'Recorded by';

  @override
  String get saveMovement => 'Save movement';

  @override
  String get shiftOnly => 'This shift only';

  @override
  String get totalRevenue => 'Total revenue';

  @override
  String get caseCount => 'Case count';

  @override
  String get expenses => 'Outgoings';

  @override
  String get dailyRevenue => 'Daily revenue';

  @override
  String get caseDistribution => 'Case distribution';

  @override
  String get period => 'Period';

  @override
  String get today => 'Today';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get custom => 'Custom range';

  @override
  String get fromDate => 'From date';

  @override
  String get toDate => 'To date';

  @override
  String get apply => 'Apply range';

  @override
  String get exportReport => 'Export report (CSV)';

  @override
  String get cashRevenue => 'Cash payments';

  @override
  String get walletRevenue => 'Wallet payments';

  @override
  String get noFinancialAccess =>
      'Administration totals stay in manager workspace';

  @override
  String get sampleOnly =>
      'Sample data — do not enter real patient information';

  @override
  String get previewGate =>
      'Preview access only; production authentication is not connected';

  @override
  String get password => 'Password';

  @override
  String get email => 'Manager email';

  @override
  String get managerName => 'Manager name';

  @override
  String get signIn => 'Enter manager workspace';

  @override
  String get wrongPassword => 'Incorrect preview password';

  @override
  String get previewPassword => 'Preview password: newcare-demo';

  @override
  String get lockManager => 'Lock manager workspace';

  @override
  String get returnNursing => 'Return to nursing';

  @override
  String get createManager => 'Save local setup & continue';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get setupSteps => 'Account → Nursing → Procedures → Ready';

  @override
  String get defaultPrice => 'Default price';

  @override
  String get procedureNameAr => 'Procedure name · Arabic';

  @override
  String get procedureNameEn => 'Procedure name · English';

  @override
  String get openingCash => 'Opening cash balance';

  @override
  String get setupComplete => 'Local workspace is ready';

  @override
  String get openNursing => 'Open nursing workspace';

  @override
  String get openManager => 'Open manager dashboard';

  @override
  String get addNursing => 'Add nursing member';

  @override
  String get isManager => 'Also a manager';

  @override
  String get active => 'Active';

  @override
  String get closed => 'Closed';

  @override
  String get open => 'Open';

  @override
  String get review => 'Needs review';

  @override
  String get name => 'Name';

  @override
  String get status => 'Status';

  @override
  String get time => 'Time';

  @override
  String get details => 'Details';

  @override
  String get currency => 'EGP';

  @override
  String get newAdvance => 'Record an advance';

  @override
  String get outstandingAdvances => 'Recorded advances';

  @override
  String get payrollPending => 'Payroll rules not configured';

  @override
  String get payrollExplanation =>
      'Agree on fixed, hourly or per-case rates before calculating salaries';

  @override
  String get advanceNote => 'A cash advance creates one linked drawer entry';

  @override
  String get saveAdvance => 'Record advance';

  @override
  String get role => 'Role';

  @override
  String get chiefManager => 'Principal manager';

  @override
  String get financeManager => 'Finance manager';

  @override
  String get operationsManager => 'Operations manager';

  @override
  String get viewTotals => 'View totals and analytics';

  @override
  String get managePayroll => 'Manage payroll and advances';

  @override
  String get manageNursing => 'Manage nursing and catalogue';

  @override
  String get editClosedShifts => 'Edit closed shifts';

  @override
  String get manageManagers => 'Manage managers and permissions';

  @override
  String get savePermissions => 'Save permissions';

  @override
  String get permissionsNote =>
      'Local role preview. Backend authorization is a separate phase';

  @override
  String get conflict => 'Conflict review';

  @override
  String get noConflict => 'No local conflicts';

  @override
  String get syncNote =>
      'Operations remain local until a backend is configured';

  @override
  String get retry => 'Review local queue';

  @override
  String get queue => 'Pending local operations';

  @override
  String get noAudit => 'No operations yet';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get english => 'English';

  @override
  String get savedNote => 'The record is saved on this device';

  @override
  String get selectStaff => 'Select a nursing member';

  @override
  String get phoneHint => 'Optional contact number';

  @override
  String get addressHint => 'Street, building, floor and landmark';

  @override
  String get titleHint => 'Brief description of the case';

  @override
  String get supplyHint => 'For example: cannula, saline, gauze';

  @override
  String get noShift => 'No active shift';

  @override
  String get startNow => 'Start shift';

  @override
  String get viewHistory => 'View shift cases';

  @override
  String get recorded => 'Recorded';

  @override
  String get saveAndContinue => 'Save and continue';

  @override
  String get configured => 'Configured locally';

  @override
  String get emptyCatalogue => 'Add your first procedure';

  @override
  String get advanceTotal => 'Advances total';

  @override
  String get cashFormula =>
      'Opening cash + cash receipts + income − outgoings − advances − awards + cash count differences';

  @override
  String get showSetup => 'First-run setup';

  @override
  String get added => 'Added successfully';

  @override
  String get noResults => 'No matching results';

  @override
  String get allStaff => 'All nursing';

  @override
  String get allTypes => 'All case types';

  @override
  String get payrollUnit =>
      'Salary calculations will appear after the policy is agreed';

  @override
  String get queueLocal => 'Local only';

  @override
  String get latestActivity => 'Latest activity';

  @override
  String get caseAdded => 'Case added';

  @override
  String get shiftStarted => 'Shift started';

  @override
  String get shiftEnded => 'Shift ended';

  @override
  String get cashAdded => 'Cash movement added';

  @override
  String get staffAdded => 'Nursing member added';

  @override
  String get procedureAdded => 'Procedure added';

  @override
  String get handoverRecorded => 'Handover recorded';

  @override
  String get settingsSaved => 'Settings saved';

  @override
  String get staffJoined => 'Nursing member joined';

  @override
  String get setupSaved => 'Local setup saved';

  @override
  String get confirmJoin => 'Confirm joining shift';

  @override
  String get selectAtLeastOne => 'Select at least one nursing member';

  @override
  String get noOpenToClose => 'There is no open shift to close';

  @override
  String get started => 'Started';

  @override
  String get offlineNote => 'Local saving continues without a cloud connection';

  @override
  String get configureBackend => 'Backend connection is not configured';

  @override
  String get requiredMark => 'Required';

  @override
  String get previewWarning => 'Local preview';

  @override
  String get selectProcedure => 'Select procedure';

  @override
  String get editData => 'Edit local data';

  @override
  String get close => 'Close';

  @override
  String get loadingWorkspace => 'Preparing your workspace';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Confirm deletion';

  @override
  String get deleteRecord => 'Delete record';

  @override
  String get changeReason => 'Reason for change';

  @override
  String get deleteNote => 'This action is recorded in the audit history';

  @override
  String get recordUpdated => 'Record updated';

  @override
  String get recordDeleted => 'Record deleted';

  @override
  String get shiftArchived => 'Shift archived';

  @override
  String get supplyAdded => 'Supply added';

  @override
  String get archiveShift => 'Archive shift';

  @override
  String get recordNotFound => 'The record no longer exists';

  @override
  String get dependencyExists => 'This record is linked to existing cases';

  @override
  String get invalidDates => 'End time must follow start time';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInSubtitle => 'Open the NewCare manager workspace';

  @override
  String get memberInactive => 'Inactive nursing member';

  @override
  String get viewRecord => 'View record';

  @override
  String get transactions => 'Transactions';

  @override
  String get casePayment => 'Case payment';

  @override
  String get dateAndTime => 'Date & time';

  @override
  String get searchTransactions =>
      'Search by description, nursing or reference';

  @override
  String get allTransactions => 'All types';

  @override
  String get allNursing => 'All nursing staff';

  @override
  String get newTransaction => 'Add cash movement';

  @override
  String get cashIn => 'Cash received';

  @override
  String get cashOut => 'Cash paid out';

  @override
  String get walletReceipts => 'Wallet receipts';

  @override
  String get netCashFlow => 'Net cash flow';

  @override
  String get transactionTotalsNote =>
      'Totals follow the selected filters. Net cash flow excludes wallet receipts and opening drawer balances.';

  @override
  String get transactionBreakdown => 'Transaction breakdown';

  @override
  String get monthlySalary => 'Monthly salary';

  @override
  String get setSalary => 'Set nursing salary';

  @override
  String get salaryRegister => 'Nursing salaries';

  @override
  String get salaryAfterAdvances => 'Salary less selected advances';

  @override
  String get salaryNote =>
      'Monthly base salary less advances in the selected period. Awards are paid cash movements, shown separately to avoid counting them twice.';

  @override
  String get addProcedure => 'Add procedure';

  @override
  String get addSupply => 'Add supply';

  @override
  String get accessLevels => 'Access levels';

  @override
  String get nursingAccess =>
      'Record cases, receive case payments and add outgoings and advances.';

  @override
  String get managerAccess =>
      'Manage nursing staff, salaries, procedures, records and the drawer, and view totals and reports. Managers may record their own cases.';

  @override
  String get shiftOpen => 'Shift is open';

  @override
  String get shiftClosed => 'Shift is closed';

  @override
  String get addCase => 'Add case';

  @override
  String get caseType => 'Case type';

  @override
  String get cardView => 'Cards';

  @override
  String get tableView => 'Table';

  @override
  String get award => 'Award';

  @override
  String get newAward => 'Add nursing award';

  @override
  String get saveAward => 'Save award';

  @override
  String get awardsTotal => 'Awards paid';

  @override
  String get salaryUpdated => 'Monthly salary updated';

  @override
  String get ended => 'Ended';

  @override
  String get shiftTiming => 'Shift times';

  @override
  String get checkDrawerFirst => 'Check the drawer before closing';

  @override
  String get checkDrawerExplanation =>
      'Select who counted the drawer, enter the actual cash, then confirm the review before closing the shift.';

  @override
  String get drawerReview => 'Drawer review';

  @override
  String get drawerCheckedBy => 'Checked and closed by';

  @override
  String get confirmDrawerReview => 'Confirm drawer count';

  @override
  String get drawerReviewDone =>
      'Drawer review confirmed. You can close this shift.';

  @override
  String get drawerChanged =>
      'Drawer data changed. Count and confirm it again.';

  @override
  String get lastShiftClosed => 'Previous shift closure';

  @override
  String get drawerUnchecked => 'Not checked';

  @override
  String get drawerMatched => 'Matched';

  @override
  String get drawerShortage => 'Shortage';

  @override
  String get drawerExcess => 'Excess';

  @override
  String get proceduresUsed => 'Procedures performed';

  @override
  String get selectedSupplies => 'Medical supplies';

  @override
  String get caseTotal => 'Calculated total';

  @override
  String get procedureTotal => 'Procedures subtotal';

  @override
  String get supplyTotal => 'Supplies subtotal';

  @override
  String get priceBreakdown => 'Total and payment';

  @override
  String get selectItems => 'Select items';

  @override
  String get noPricedSupplies => 'No supplies in the catalogue';

  @override
  String get chooseDay => 'Choose a day';

  @override
  String get caseFormSubtitle =>
      'Select procedures and enter the case total and amount paid; the remaining balance is calculated automatically.';

  @override
  String get procedureRequired => 'Select at least one procedure';

  @override
  String get itemName => 'Name';

  @override
  String get price => 'Price';

  @override
  String get supplyNameHint => 'e.g. Cannula';

  @override
  String get procedureNameHint => 'e.g. IV infusion';

  @override
  String get priceHint => 'Enter the price in Egyptian pounds';

  @override
  String get shiftDetails => 'Shift details';

  @override
  String get allPayments => 'All payment methods';

  @override
  String get translationUnavailable => 'Unavailable';

  @override
  String get caseUpdated => 'Case updated';

  @override
  String get brandName => 'NewCare';

  @override
  String get nursingCareServices => 'Nursing care services';

  @override
  String get caseRegister => 'Record cases';

  @override
  String get caseBook => 'Case book';

  @override
  String get catalogueTotal => 'Procedure price subtotal';

  @override
  String get agreedPrice => 'Case total';

  @override
  String get paidNow => 'Paid at registration';

  @override
  String get remainingAmount => 'Remaining';

  @override
  String get paidTotal => 'Total paid';

  @override
  String get laterPayments => 'Recorded subsequent payments';

  @override
  String get paymentHistory => 'Case payment history';

  @override
  String get initialPayment => 'Initial payment';

  @override
  String get receivePayment => 'Receive payment';

  @override
  String get paymentAmount => 'Payment amount';

  @override
  String get savePayment => 'Save payment';

  @override
  String get casePaymentAdded => 'Case payment received';

  @override
  String get invalidPaymentAmount =>
      'Enter a valid amount within the outstanding balance; the agreed price cannot be less than receipts';

  @override
  String get searchCatalogue => 'Search and select a procedure…';

  @override
  String get caseReference => 'Case reference';

  @override
  String get searchCaseBook =>
      'Search by procedure, address, nursing staff or case reference';

  @override
  String get outstandingCases => 'Outstanding cases';

  @override
  String get outstandingAllDates => 'Outstanding cases from all dates';

  @override
  String get drawerBalance => 'Current drawer balance';

  @override
  String get payInFull => 'Pay in full';

  @override
  String get externalAdvance => 'Advance';

  @override
  String get centerExpense => 'Center outgoings';

  @override
  String get externalRecipient => 'Recipient name';

  @override
  String get recipientRequired => 'Enter the recipient name';

  @override
  String get drawerHandover => 'Hand over drawer';

  @override
  String get drawerHandoverNote =>
      'Count the cash and select the sender and receiver. Count differences are recorded separately and are not revenue or outgoings.';

  @override
  String get drawerFrom => 'Handed over by';

  @override
  String get drawerTo => 'Received by';

  @override
  String get drawerHolder => 'Current drawer holder';

  @override
  String get drawerHandoverHistory => 'Drawer custody history';

  @override
  String get confirmDrawerHandover => 'Confirm drawer handover';

  @override
  String get handoverDifferenceReason =>
      'Notes and reason for a shortage or excess';

  @override
  String get invalidHandoverStaff =>
      'The current drawer holder must hand over to a different person';

  @override
  String get drawerHandedOver => 'Drawer custody handed over';

  @override
  String get refreshDrawer => 'Refresh count baseline';

  @override
  String get editCasePrice => 'Edit case total';

  @override
  String get priceBelowPaid =>
      'The price cannot be less than the amount already received';

  @override
  String get priceEditNote =>
      'Changing the case total does not change recorded receipts.';

  @override
  String get casePriceUpdated => 'Case price updated';

  @override
  String get notes => 'Notes';

  @override
  String get personOutgoings => 'Person outgoings';

  @override
  String get recordOutgoing => 'Record outgoing';

  @override
  String get outgoings => 'Outgoings';

  @override
  String get saveOutgoing => 'Save outgoing';

  @override
  String get personPaymentPurpose => 'Payment purpose';

  @override
  String get otherPersonOutgoing => 'Other payment';

  @override
  String get otherPerson => 'Other person';

  @override
  String get personName => 'Person name';

  @override
  String get personNursingRecipient => 'Nursing recipient';

  @override
  String get outgoingDescription => 'Description';

  @override
  String get centerOutgoingHint => 'e.g. Rent, electricity or purchases';

  @override
  String get personOutgoingHint => 'e.g. Fees or a refund';

  @override
  String get incomeDescriptionHint => 'e.g. A cash deposit into the drawer';

  @override
  String get personOutgoingHelp =>
      'Choose the payment purpose and recipient, then enter the amount. Advances are part of person outgoings.';

  @override
  String get centerOutgoingHelp =>
      'For rent, electricity, purchases and other center outgoings.';

  @override
  String get noOtherDrawerReceiver =>
      'Another person is needed to receive the drawer. The sender cannot receive it from themselves.';

  @override
  String get openNavigation => 'Open navigation';

  @override
  String get closeNavigation => 'Close navigation';

  @override
  String get hideSidebar => 'Hide sidebar';

  @override
  String get showSidebar => 'Show sidebar';

  @override
  String get devicePreview => 'Device preview';

  @override
  String get previewDebugOnly =>
      'Preview controls are available in debug mode only';

  @override
  String get previewDevice => 'Device and screen size';

  @override
  String get previewPlatform => 'Platform';

  @override
  String get previewTextScale => 'Text scale';

  @override
  String get previewRotate => 'Rotate screen';

  @override
  String get previewKeyboard => 'Toggle keyboard';

  @override
  String get previewReset => 'Actual device';

  @override
  String get previewFailed => 'Could not change preview';

  @override
  String get squareMonitor => 'Square monitor 1024 × 1024';

  @override
  String get platformandroid => 'Android';

  @override
  String get platformiOS => 'iOS';

  @override
  String get platformwindows => 'Windows';

  @override
  String get platformmacOS => 'macOS';

  @override
  String get platformlinux => 'Linux';

  @override
  String get platformfuchsia => 'Fuchsia';

  @override
  String get changePassword => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get passwordTooShort => 'Use at least 8 characters';

  @override
  String get passwordUpdated => 'Password updated';

  @override
  String get settingsSaveFailed => 'Could not save changes. Try again.';

  @override
  String get navigationLabels => 'Navigation section names';

  @override
  String get navigationLabelsHelp =>
      'Edit section names for the current language. Leave a field empty to use its original name.';

  @override
  String get restoreNavigationLabels => 'Restore original names';

  @override
  String get navigationLabelTooLong => 'Use no more than 40 characters';

  @override
  String get drawerStatus => 'Drawer status';

  @override
  String get cashDrawerHint =>
      'The balance updates automatically with cash receipts and outgoings. Wallet payments stay outside the drawer.';

  @override
  String get unassignedDrawerHolder => 'No custodian assigned yet';

  @override
  String get lastDrawerCheck => 'Last cash count result';

  @override
  String get allPaymentMethods => 'All';

  @override
  String get caseAddedAt => 'Date and time added';
}
