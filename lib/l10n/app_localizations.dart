import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NewCare'**
  String get appTitle;

  /// No description provided for @localPreview.
  ///
  /// In en, this message translates to:
  /// **'Local preview · sample data'**
  String get localPreview;

  /// No description provided for @localSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device'**
  String get localSaved;

  /// No description provided for @pendingSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync not configured'**
  String get pendingSync;

  /// No description provided for @nursing.
  ///
  /// In en, this message translates to:
  /// **'Nursing'**
  String get nursing;

  /// No description provided for @manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// No description provided for @managerArea.
  ///
  /// In en, this message translates to:
  /// **'Manager workspace'**
  String get managerArea;

  /// No description provided for @nurseArea.
  ///
  /// In en, this message translates to:
  /// **'Nursing workspace'**
  String get nurseArea;

  /// No description provided for @shift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get shift;

  /// No description provided for @cases.
  ///
  /// In en, this message translates to:
  /// **'Cases'**
  String get cases;

  /// No description provided for @drawer.
  ///
  /// In en, this message translates to:
  /// **'Cash drawer'**
  String get drawer;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Analytics overview'**
  String get overview;

  /// No description provided for @shifts.
  ///
  /// In en, this message translates to:
  /// **'Shifts & drawer'**
  String get shifts;

  /// No description provided for @caseLog.
  ///
  /// In en, this message translates to:
  /// **'Case log'**
  String get caseLog;

  /// No description provided for @payroll.
  ///
  /// In en, this message translates to:
  /// **'Payroll & advances'**
  String get payroll;

  /// No description provided for @catalogue.
  ///
  /// In en, this message translates to:
  /// **'Procedures & supplies'**
  String get catalogue;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Settings & permissions'**
  String get permissions;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @audit.
  ///
  /// In en, this message translates to:
  /// **'Audit & sync'**
  String get audit;

  /// No description provided for @startShift.
  ///
  /// In en, this message translates to:
  /// **'Start a new shift'**
  String get startShift;

  /// No description provided for @activeShift.
  ///
  /// In en, this message translates to:
  /// **'Current shift'**
  String get activeShift;

  /// No description provided for @insideCase.
  ///
  /// In en, this message translates to:
  /// **'Inside-center case'**
  String get insideCase;

  /// No description provided for @outsideCase.
  ///
  /// In en, this message translates to:
  /// **'Outside-center case'**
  String get outsideCase;

  /// No description provided for @caseDetails.
  ///
  /// In en, this message translates to:
  /// **'Case details'**
  String get caseDetails;

  /// No description provided for @cashMovement.
  ///
  /// In en, this message translates to:
  /// **'Cash movement'**
  String get cashMovement;

  /// No description provided for @endShift.
  ///
  /// In en, this message translates to:
  /// **'End shift'**
  String get endShift;

  /// No description provided for @handover.
  ///
  /// In en, this message translates to:
  /// **'Receive shift'**
  String get handover;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Local operation queue'**
  String get offline;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get saved;

  /// No description provided for @shiftCases.
  ///
  /// In en, this message translates to:
  /// **'Shift cases'**
  String get shiftCases;

  /// No description provided for @joinShift.
  ///
  /// In en, this message translates to:
  /// **'Add nursing to shift'**
  String get joinShift;

  /// No description provided for @matched.
  ///
  /// In en, this message translates to:
  /// **'Drawer reconciled'**
  String get matched;

  /// No description provided for @validation.
  ///
  /// In en, this message translates to:
  /// **'Review visit details'**
  String get validation;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Manager sign-in'**
  String get login;

  /// No description provided for @setup.
  ///
  /// In en, this message translates to:
  /// **'Set up NewCare'**
  String get setup;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Custom date range'**
  String get dateRange;

  /// No description provided for @setupNursing.
  ///
  /// In en, this message translates to:
  /// **'Add nursing members'**
  String get setupNursing;

  /// No description provided for @setupCatalogue.
  ///
  /// In en, this message translates to:
  /// **'Procedures & opening cash'**
  String get setupCatalogue;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready to start'**
  String get ready;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveCase.
  ///
  /// In en, this message translates to:
  /// **'Save case'**
  String get saveCase;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @inside.
  ///
  /// In en, this message translates to:
  /// **'Inside center'**
  String get inside;

  /// No description provided for @outside.
  ///
  /// In en, this message translates to:
  /// **'Outside center'**
  String get outside;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get amount;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @caseTitle.
  ///
  /// In en, this message translates to:
  /// **'Case title'**
  String get caseTitle;

  /// No description provided for @procedure.
  ///
  /// In en, this message translates to:
  /// **'Procedure'**
  String get procedure;

  /// No description provided for @supplies.
  ///
  /// In en, this message translates to:
  /// **'Supplies and quantities'**
  String get supplies;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Visit address'**
  String get address;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone · optional'**
  String get phoneOptional;

  /// No description provided for @caseOwner.
  ///
  /// In en, this message translates to:
  /// **'Responsible nursing member'**
  String get caseOwner;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'An outside visit needs an address'**
  String get addressRequired;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid non-negative amount'**
  String get invalidAmount;

  /// No description provided for @noOpenShift.
  ///
  /// In en, this message translates to:
  /// **'Start a shift before recording cases'**
  String get noOpenShift;

  /// No description provided for @shiftAlreadyOpen.
  ///
  /// In en, this message translates to:
  /// **'A shift is already open'**
  String get shiftAlreadyOpen;

  /// No description provided for @unknownStaff.
  ///
  /// In en, this message translates to:
  /// **'Choose an active nursing member'**
  String get unknownStaff;

  /// No description provided for @staffNotInShift.
  ///
  /// In en, this message translates to:
  /// **'This nursing member is not on the shift'**
  String get staffNotInShift;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Explain the drawer difference'**
  String get reasonRequired;

  /// No description provided for @invalidProcedure.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid procedure'**
  String get invalidProcedure;

  /// No description provided for @storageFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again'**
  String get storageFailed;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the operation'**
  String get saveFailed;

  /// No description provided for @memberName.
  ///
  /// In en, this message translates to:
  /// **'Nursing member name'**
  String get memberName;

  /// No description provided for @currentNursing.
  ///
  /// In en, this message translates to:
  /// **'Nursing on this shift'**
  String get currentNursing;

  /// No description provided for @lastCases.
  ///
  /// In en, this message translates to:
  /// **'Latest shift cases'**
  String get lastCases;

  /// No description provided for @noCases.
  ///
  /// In en, this message translates to:
  /// **'No cases recorded yet'**
  String get noCases;

  /// No description provided for @newCase.
  ///
  /// In en, this message translates to:
  /// **'Record another case'**
  String get newCase;

  /// No description provided for @returnShift.
  ///
  /// In en, this message translates to:
  /// **'Return to current shift'**
  String get returnShift;

  /// No description provided for @addInside.
  ///
  /// In en, this message translates to:
  /// **'Add inside-center case'**
  String get addInside;

  /// No description provided for @addOutside.
  ///
  /// In en, this message translates to:
  /// **'Add home visit'**
  String get addOutside;

  /// No description provided for @chooseStarter.
  ///
  /// In en, this message translates to:
  /// **'Who is starting this shift?'**
  String get chooseStarter;

  /// No description provided for @receiveDrawer.
  ///
  /// In en, this message translates to:
  /// **'Continue to drawer handover'**
  String get receiveDrawer;

  /// No description provided for @expectedCash.
  ///
  /// In en, this message translates to:
  /// **'Expected cash'**
  String get expectedCash;

  /// No description provided for @countedCash.
  ///
  /// In en, this message translates to:
  /// **'Counted cash'**
  String get countedCash;

  /// No description provided for @difference.
  ///
  /// In en, this message translates to:
  /// **'Drawer difference'**
  String get difference;

  /// No description provided for @differenceReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for difference'**
  String get differenceReason;

  /// No description provided for @confirmHandover.
  ///
  /// In en, this message translates to:
  /// **'Confirm receipt & start shift'**
  String get confirmHandover;

  /// No description provided for @varianceNote.
  ///
  /// In en, this message translates to:
  /// **'The difference is recorded for manager review'**
  String get varianceNote;

  /// No description provided for @balancedNote.
  ///
  /// In en, this message translates to:
  /// **'Count matches expected cash'**
  String get balancedNote;

  /// No description provided for @handoverNote.
  ///
  /// In en, this message translates to:
  /// **'Only cash is counted; wallet payments are separate'**
  String get handoverNote;

  /// No description provided for @finishNote.
  ///
  /// In en, this message translates to:
  /// **'Confirm all home visits are recorded before closing'**
  String get finishNote;

  /// No description provided for @handoverNotes.
  ///
  /// In en, this message translates to:
  /// **'Handover notes'**
  String get handoverNotes;

  /// No description provided for @finishShift.
  ///
  /// In en, this message translates to:
  /// **'Close shift & prepare handover'**
  String get finishShift;

  /// No description provided for @staffBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Cases by nursing member'**
  String get staffBreakdown;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @openedAt.
  ///
  /// In en, this message translates to:
  /// **'Started at'**
  String get openedAt;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Cash received'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @advance.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get advance;

  /// No description provided for @movementKind.
  ///
  /// In en, this message translates to:
  /// **'Movement type'**
  String get movementKind;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @recordedBy.
  ///
  /// In en, this message translates to:
  /// **'Recorded by'**
  String get recordedBy;

  /// No description provided for @saveMovement.
  ///
  /// In en, this message translates to:
  /// **'Save movement'**
  String get saveMovement;

  /// No description provided for @shiftOnly.
  ///
  /// In en, this message translates to:
  /// **'This shift only'**
  String get shiftOnly;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total revenue'**
  String get totalRevenue;

  /// No description provided for @caseCount.
  ///
  /// In en, this message translates to:
  /// **'Case count'**
  String get caseCount;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @dailyRevenue.
  ///
  /// In en, this message translates to:
  /// **'Daily revenue'**
  String get dailyRevenue;

  /// No description provided for @caseDistribution.
  ///
  /// In en, this message translates to:
  /// **'Case distribution'**
  String get caseDistribution;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get custom;

  /// No description provided for @fromDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get fromDate;

  /// No description provided for @toDate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get toDate;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply range'**
  String get apply;

  /// No description provided for @exportReport.
  ///
  /// In en, this message translates to:
  /// **'Export report (CSV)'**
  String get exportReport;

  /// No description provided for @cashRevenue.
  ///
  /// In en, this message translates to:
  /// **'Cash payments'**
  String get cashRevenue;

  /// No description provided for @walletRevenue.
  ///
  /// In en, this message translates to:
  /// **'Wallet payments'**
  String get walletRevenue;

  /// No description provided for @noFinancialAccess.
  ///
  /// In en, this message translates to:
  /// **'Administration totals stay in manager workspace'**
  String get noFinancialAccess;

  /// No description provided for @sampleOnly.
  ///
  /// In en, this message translates to:
  /// **'Sample data — do not enter real patient information'**
  String get sampleOnly;

  /// No description provided for @previewGate.
  ///
  /// In en, this message translates to:
  /// **'Preview access only; production authentication is not connected'**
  String get previewGate;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Manager email'**
  String get email;

  /// No description provided for @managerName.
  ///
  /// In en, this message translates to:
  /// **'Manager name'**
  String get managerName;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Enter manager workspace'**
  String get signIn;

  /// No description provided for @wrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect preview password'**
  String get wrongPassword;

  /// No description provided for @previewPassword.
  ///
  /// In en, this message translates to:
  /// **'Preview password: newcare-demo'**
  String get previewPassword;

  /// No description provided for @lockManager.
  ///
  /// In en, this message translates to:
  /// **'Lock manager workspace'**
  String get lockManager;

  /// No description provided for @returnNursing.
  ///
  /// In en, this message translates to:
  /// **'Return to nursing'**
  String get returnNursing;

  /// No description provided for @createManager.
  ///
  /// In en, this message translates to:
  /// **'Save local setup & continue'**
  String get createManager;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @setupSteps.
  ///
  /// In en, this message translates to:
  /// **'Account → Nursing → Procedures → Ready'**
  String get setupSteps;

  /// No description provided for @defaultPrice.
  ///
  /// In en, this message translates to:
  /// **'Default price'**
  String get defaultPrice;

  /// No description provided for @procedureNameAr.
  ///
  /// In en, this message translates to:
  /// **'Procedure name · Arabic'**
  String get procedureNameAr;

  /// No description provided for @procedureNameEn.
  ///
  /// In en, this message translates to:
  /// **'Procedure name · English'**
  String get procedureNameEn;

  /// No description provided for @openingCash.
  ///
  /// In en, this message translates to:
  /// **'Opening cash balance'**
  String get openingCash;

  /// No description provided for @setupComplete.
  ///
  /// In en, this message translates to:
  /// **'Local workspace is ready'**
  String get setupComplete;

  /// No description provided for @openNursing.
  ///
  /// In en, this message translates to:
  /// **'Open nursing workspace'**
  String get openNursing;

  /// No description provided for @openManager.
  ///
  /// In en, this message translates to:
  /// **'Open manager dashboard'**
  String get openManager;

  /// No description provided for @addNursing.
  ///
  /// In en, this message translates to:
  /// **'Add nursing member'**
  String get addNursing;

  /// No description provided for @isManager.
  ///
  /// In en, this message translates to:
  /// **'Also a manager'**
  String get isManager;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get review;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'EGP'**
  String get currency;

  /// No description provided for @newAdvance.
  ///
  /// In en, this message translates to:
  /// **'Record an advance'**
  String get newAdvance;

  /// No description provided for @outstandingAdvances.
  ///
  /// In en, this message translates to:
  /// **'Recorded advances'**
  String get outstandingAdvances;

  /// No description provided for @payrollPending.
  ///
  /// In en, this message translates to:
  /// **'Payroll rules not configured'**
  String get payrollPending;

  /// No description provided for @payrollExplanation.
  ///
  /// In en, this message translates to:
  /// **'Agree on fixed, hourly or per-case rates before calculating salaries'**
  String get payrollExplanation;

  /// No description provided for @advanceNote.
  ///
  /// In en, this message translates to:
  /// **'A cash advance creates one linked drawer entry'**
  String get advanceNote;

  /// No description provided for @saveAdvance.
  ///
  /// In en, this message translates to:
  /// **'Record advance'**
  String get saveAdvance;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @chiefManager.
  ///
  /// In en, this message translates to:
  /// **'Principal manager'**
  String get chiefManager;

  /// No description provided for @financeManager.
  ///
  /// In en, this message translates to:
  /// **'Finance manager'**
  String get financeManager;

  /// No description provided for @operationsManager.
  ///
  /// In en, this message translates to:
  /// **'Operations manager'**
  String get operationsManager;

  /// No description provided for @viewTotals.
  ///
  /// In en, this message translates to:
  /// **'View totals and analytics'**
  String get viewTotals;

  /// No description provided for @managePayroll.
  ///
  /// In en, this message translates to:
  /// **'Manage payroll and advances'**
  String get managePayroll;

  /// No description provided for @manageNursing.
  ///
  /// In en, this message translates to:
  /// **'Manage nursing and catalogue'**
  String get manageNursing;

  /// No description provided for @editClosedShifts.
  ///
  /// In en, this message translates to:
  /// **'Edit closed shifts'**
  String get editClosedShifts;

  /// No description provided for @manageManagers.
  ///
  /// In en, this message translates to:
  /// **'Manage managers and permissions'**
  String get manageManagers;

  /// No description provided for @savePermissions.
  ///
  /// In en, this message translates to:
  /// **'Save permissions'**
  String get savePermissions;

  /// No description provided for @permissionsNote.
  ///
  /// In en, this message translates to:
  /// **'Local role preview. Backend authorization is a separate phase'**
  String get permissionsNote;

  /// No description provided for @conflict.
  ///
  /// In en, this message translates to:
  /// **'Conflict review'**
  String get conflict;

  /// No description provided for @noConflict.
  ///
  /// In en, this message translates to:
  /// **'No local conflicts'**
  String get noConflict;

  /// No description provided for @syncNote.
  ///
  /// In en, this message translates to:
  /// **'Operations remain local until a backend is configured'**
  String get syncNote;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Review local queue'**
  String get retry;

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'Pending local operations'**
  String get queue;

  /// No description provided for @noAudit.
  ///
  /// In en, this message translates to:
  /// **'No operations yet'**
  String get noAudit;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @savedNote.
  ///
  /// In en, this message translates to:
  /// **'The record is saved on this device'**
  String get savedNote;

  /// No description provided for @selectStaff.
  ///
  /// In en, this message translates to:
  /// **'Select a nursing member'**
  String get selectStaff;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Optional contact number'**
  String get phoneHint;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, building, floor and landmark'**
  String get addressHint;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Brief description of the case'**
  String get titleHint;

  /// No description provided for @supplyHint.
  ///
  /// In en, this message translates to:
  /// **'One item and quantity per line'**
  String get supplyHint;

  /// No description provided for @noShift.
  ///
  /// In en, this message translates to:
  /// **'No active shift'**
  String get noShift;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start shift'**
  String get startNow;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View shift cases'**
  String get viewHistory;

  /// No description provided for @recorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get recorded;

  /// No description provided for @saveAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Save and continue'**
  String get saveAndContinue;

  /// No description provided for @configured.
  ///
  /// In en, this message translates to:
  /// **'Configured locally'**
  String get configured;

  /// No description provided for @emptyCatalogue.
  ///
  /// In en, this message translates to:
  /// **'Add your first procedure'**
  String get emptyCatalogue;

  /// No description provided for @advanceTotal.
  ///
  /// In en, this message translates to:
  /// **'Advances total'**
  String get advanceTotal;

  /// No description provided for @cashFormula.
  ///
  /// In en, this message translates to:
  /// **'Opening + cash payments + income − expenses − advances'**
  String get cashFormula;

  /// No description provided for @showSetup.
  ///
  /// In en, this message translates to:
  /// **'First-run setup'**
  String get showSetup;

  /// No description provided for @added.
  ///
  /// In en, this message translates to:
  /// **'Added successfully'**
  String get added;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No matching results'**
  String get noResults;

  /// No description provided for @allStaff.
  ///
  /// In en, this message translates to:
  /// **'All nursing'**
  String get allStaff;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All case types'**
  String get allTypes;

  /// No description provided for @payrollUnit.
  ///
  /// In en, this message translates to:
  /// **'Salary calculations will appear after the policy is agreed'**
  String get payrollUnit;

  /// No description provided for @queueLocal.
  ///
  /// In en, this message translates to:
  /// **'Local only'**
  String get queueLocal;

  /// No description provided for @latestActivity.
  ///
  /// In en, this message translates to:
  /// **'Latest activity'**
  String get latestActivity;

  /// No description provided for @caseAdded.
  ///
  /// In en, this message translates to:
  /// **'Case added'**
  String get caseAdded;

  /// No description provided for @shiftStarted.
  ///
  /// In en, this message translates to:
  /// **'Shift started'**
  String get shiftStarted;

  /// No description provided for @shiftEnded.
  ///
  /// In en, this message translates to:
  /// **'Shift ended'**
  String get shiftEnded;

  /// No description provided for @cashAdded.
  ///
  /// In en, this message translates to:
  /// **'Cash movement added'**
  String get cashAdded;

  /// No description provided for @staffAdded.
  ///
  /// In en, this message translates to:
  /// **'Nursing member added'**
  String get staffAdded;

  /// No description provided for @procedureAdded.
  ///
  /// In en, this message translates to:
  /// **'Procedure added'**
  String get procedureAdded;

  /// No description provided for @handoverRecorded.
  ///
  /// In en, this message translates to:
  /// **'Handover recorded'**
  String get handoverRecorded;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSaved;

  /// No description provided for @staffJoined.
  ///
  /// In en, this message translates to:
  /// **'Nursing member joined'**
  String get staffJoined;

  /// No description provided for @setupSaved.
  ///
  /// In en, this message translates to:
  /// **'Local setup saved'**
  String get setupSaved;

  /// No description provided for @confirmJoin.
  ///
  /// In en, this message translates to:
  /// **'Confirm joining shift'**
  String get confirmJoin;

  /// No description provided for @selectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one nursing member'**
  String get selectAtLeastOne;

  /// No description provided for @noOpenToClose.
  ///
  /// In en, this message translates to:
  /// **'There is no open shift to close'**
  String get noOpenToClose;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @offlineNote.
  ///
  /// In en, this message translates to:
  /// **'Local saving continues without a cloud connection'**
  String get offlineNote;

  /// No description provided for @configureBackend.
  ///
  /// In en, this message translates to:
  /// **'Backend connection is not configured'**
  String get configureBackend;

  /// No description provided for @requiredMark.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredMark;

  /// No description provided for @previewWarning.
  ///
  /// In en, this message translates to:
  /// **'Local preview'**
  String get previewWarning;

  /// No description provided for @selectProcedure.
  ///
  /// In en, this message translates to:
  /// **'Select procedure'**
  String get selectProcedure;

  /// No description provided for @editData.
  ///
  /// In en, this message translates to:
  /// **'Edit local data'**
  String get editData;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
