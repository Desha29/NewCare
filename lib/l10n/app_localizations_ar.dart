// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get deleteStockItem => 'حذف المستلزم';

  @override
  String get deleteStockItemHelp =>
      'سيُحذف الصنف ورصيده من المخزون. ستظل المستلزمات المسجلة في الحالات السابقة محفوظة.';

  @override
  String get deleteLabTest => 'حذف التحليل';

  @override
  String get deleteLabTestHelp =>
      'سيُحذف التحليل من القائمة. ستظل الطلبات والمدفوعات السابقة محفوظة.';

  @override
  String get startupWelcome => 'مرحبًا بك في NewCare';

  @override
  String get startupSetupHelp => 'أنشئ حساب المدير لبدء تجهيز المركز.';

  @override
  String get startupSignInTitle => 'دخول المدير';

  @override
  String get startupSignInHelp => 'سجّل الدخول لربط جهاز المركز بحسابك.';

  @override
  String get startupExistingAccount => 'لدي حساب مدير بالفعل';

  @override
  String get startupCreateInstead => 'إنشاء حساب مدير جديد';

  @override
  String get syncVerificationUnavailable =>
      'تعذّر التحقق من السحابة حاليًا — البيانات محفوظة محليًا';

  @override
  String get syncVerificationPending =>
      'توجد تغييرات جديدة — أعد التحقق بعد المزامنة';

  @override
  String get syncVerificationDifferent =>
      'البيانات المحلية والسحابية غير متطابقة';

  @override
  String get syncVerificationMatched =>
      'متطابقين — تم التحقق من المحتوى والإصدار';

  @override
  String get stockMovements => 'حركات المخزون';

  @override
  String get chooseManager => 'اختر حساب المدير';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get appTitle => 'نيو كير';

  @override
  String get localPreview => 'معاينة محلية · بيانات توضيحية';

  @override
  String get localSaved => 'محفوظ على الجهاز';

  @override
  String get pendingSync => 'المزامنة السحابية غير مفعّلة';

  @override
  String get syncOnline => 'متصل بالسحابة';

  @override
  String get syncing => 'جارٍ مزامنة العمليات';

  @override
  String get syncOffline => 'غير متصل — تم الحفظ محليًا';

  @override
  String get syncPending => 'معلّقة';

  @override
  String get nursing => 'التمريض';

  @override
  String get manager => 'مدير';

  @override
  String get managerArea => 'مساحة المدير';

  @override
  String get nurseArea => 'مساحة التمريض';

  @override
  String get shift => 'الشيفت';

  @override
  String get cases => 'الحالات';

  @override
  String get drawer => 'الدرج';

  @override
  String get settings => 'الإعدادات';

  @override
  String get overview => 'لوحة التحليلات';

  @override
  String get shifts => 'الشيفتات والدرج';

  @override
  String get caseLog => 'سجل الحالات';

  @override
  String get payroll => 'المرتبات والسلف';

  @override
  String get catalogue => 'الإجراءات';

  @override
  String get permissions => 'الإعدادات';

  @override
  String get reports => 'التقارير';

  @override
  String get audit => 'سجل التدقيق والمزامنة';

  @override
  String get startShift => 'ابدأ شيفت جديد';

  @override
  String get activeShift => 'الشيفت الحالي';

  @override
  String get insideCase => 'حالة داخل المركز';

  @override
  String get outsideCase => 'حالة خارج المركز';

  @override
  String get caseDetails => 'تفاصيل الحالة';

  @override
  String get cashMovement => 'حركة الدرج';

  @override
  String get endShift => 'إنهاء الشيفت';

  @override
  String get handover => 'استلام الشيفت';

  @override
  String get offline => 'عمليات محفوظة محليًا';

  @override
  String get saved => 'تم الحفظ بنجاح';

  @override
  String get shiftCases => 'حالات الشيفت';

  @override
  String get joinShift => 'إضافة تمريض للشيفت';

  @override
  String get matched => 'الدرج مطابق';

  @override
  String get validation => 'راجع بيانات الزيارة';

  @override
  String get login => 'دخول المدير';

  @override
  String get setup => 'إعداد نيو كير';

  @override
  String get dateRange => 'فترة مخصصة';

  @override
  String get setupNursing => 'إضافة التمريض';

  @override
  String get setupCatalogue => 'الإجراءات ورصيد البداية';

  @override
  String get ready => 'جاهز للعمل';

  @override
  String get save => 'حفظ';

  @override
  String get saveCase => 'حفظ الحالة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get back => 'رجوع';

  @override
  String get continueAction => 'متابعة';

  @override
  String get add => 'إضافة';

  @override
  String get edit => 'تعديل';

  @override
  String get search => 'بحث';

  @override
  String get all => 'الكل';

  @override
  String get inside => 'داخل المركز';

  @override
  String get outside => 'خارج المركز';

  @override
  String get cash => 'كاش';

  @override
  String get wallet => 'محفظة';

  @override
  String get amount => 'المبلغ المدفوع';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get caseTitle => 'عنوان الحالة';

  @override
  String get procedure => 'الإجراء';

  @override
  String get supplies => 'المستلزمات';

  @override
  String get address => 'عنوان الزيارة';

  @override
  String get phoneOptional => 'الهاتف · اختياري';

  @override
  String get caseOwner => 'التمريض المسؤول';

  @override
  String get choose => 'اختر';

  @override
  String get requiredField => 'هذا الحقل مطلوب';

  @override
  String get addressRequired => 'العنوان مطلوب للزيارة الخارجية';

  @override
  String get invalidAmount => 'أدخل مبلغًا صحيحًا غير سالب';

  @override
  String get noOpenShift => 'ابدأ شيفت قبل تسجيل الحالات';

  @override
  String get shiftAlreadyOpen => 'يوجد شيفت مفتوح بالفعل';

  @override
  String get unknownStaff => 'اختر فرد تمريض نشطًا';

  @override
  String get staffNotInShift => 'فرد التمريض غير موجود في الشيفت';

  @override
  String get reasonRequired => 'أضف سبب فرق الدرج';

  @override
  String get invalidProcedure => 'اختر إجراءً صحيحًا';

  @override
  String get storageFailed => 'تعذّر الحفظ، حاول مرة أخرى';

  @override
  String get saveFailed => 'تعذّر إتمام العملية';

  @override
  String get memberName => 'اسم فرد التمريض';

  @override
  String get currentNursing => 'التمريض الموجود في الشيفت';

  @override
  String get lastCases => 'آخر حالات الشيفت';

  @override
  String get noCases => 'لا توجد حالات مسجلة بعد';

  @override
  String get newCase => 'تسجيل حالة أخرى';

  @override
  String get returnShift => 'العودة لتسجيل الحالات';

  @override
  String get addInside => 'إضافة حالة داخل المركز';

  @override
  String get addOutside => 'إضافة حالة خارج المركز';

  @override
  String get chooseStarter => 'مين هيبدأ الشيفت؟';

  @override
  String get receiveDrawer => 'متابعة إلى استلام الدرج';

  @override
  String get expectedCash => 'النقدية المتوقعة';

  @override
  String get countedCash => 'النقدية المعدودة';

  @override
  String get difference => 'فرق الدرج';

  @override
  String get differenceReason => 'سبب الفرق';

  @override
  String get confirmHandover => 'تأكيد الاستلام وبدء الشيفت';

  @override
  String get varianceNote => 'يُسجل الفرق لمراجعة المدير';

  @override
  String get balancedNote => 'النقدية المعدودة تطابق المتوقع';

  @override
  String get handoverNote => 'عدّ النقدية فقط؛ مدفوعات المحفظة منفصلة';

  @override
  String get finishNote => 'تأكد من تسجيل الزيارات الخارجية قبل الإنهاء';

  @override
  String get handoverNotes => 'ملاحظات التسليم';

  @override
  String get finishShift => 'إنهاء الشيفت وتجهيز التسليم';

  @override
  String get staffBreakdown => 'الحالات لكل فرد تمريض';

  @override
  String get duration => 'المدة';

  @override
  String get openedAt => 'بدأ';

  @override
  String get income => 'وارد نقدي';

  @override
  String get expense => 'خوارج';

  @override
  String get advance => 'سلفة';

  @override
  String get movementKind => 'نوع الحركة';

  @override
  String get reason => 'السبب';

  @override
  String get recordedBy => 'سجّلها مين؟';

  @override
  String get saveMovement => 'حفظ الحركة';

  @override
  String get shiftOnly => 'هذا الشيفت فقط';

  @override
  String get totalRevenue => 'إجمالي الإيراد';

  @override
  String get caseCount => 'عدد الحالات';

  @override
  String get expenses => 'الخوارج';

  @override
  String get dailyRevenue => 'الإيراد اليومي';

  @override
  String get caseDistribution => 'توزيع الحالات';

  @override
  String get period => 'الفترة';

  @override
  String get today => 'اليوم';

  @override
  String get week => 'الأسبوع';

  @override
  String get month => 'الشهر';

  @override
  String get custom => 'فترة مخصصة';

  @override
  String get fromDate => 'من تاريخ';

  @override
  String get toDate => 'إلى تاريخ';

  @override
  String get apply => 'تطبيق الفترة';

  @override
  String get exportReport => 'تصدير التقرير CSV';

  @override
  String get cashRevenue => 'مدفوعات الكاش';

  @override
  String get walletRevenue => 'مدفوعات المحفظة';

  @override
  String get noFinancialAccess => 'إجماليات الإدارة متاحة داخل مساحة المدير';

  @override
  String get sampleOnly => 'بيانات توضيحية — لا تُدخل بيانات مرضى حقيقية';

  @override
  String get previewGate => 'دخول تجريبي فقط؛ المصادقة الفعلية لم تُربط بعد';

  @override
  String get password => 'كلمة المرور';

  @override
  String get email => 'بريد المدير';

  @override
  String get managerName => 'اسم المدير';

  @override
  String get signIn => 'دخول مساحة المدير';

  @override
  String get wrongPassword => 'كلمة مرور المعاينة غير صحيحة';

  @override
  String get previewPassword => 'كلمة المرور المحلية الافتراضية: 12345678';

  @override
  String get lockManager => 'قفل مساحة المدير';

  @override
  String get returnNursing => 'رجوع للتمريض';

  @override
  String get createManager => 'حفظ الإعداد المحلي والمتابعة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get setupSteps => 'الحساب ← التمريض ← الإجراءات ← جاهز';

  @override
  String get defaultPrice => 'السعر الافتراضي';

  @override
  String get procedureNameAr => 'اسم الإجراء بالعربي';

  @override
  String get procedureNameEn => 'اسم الإجراء بالإنجليزي';

  @override
  String get openingCash => 'رصيد الدرج الافتتاحي';

  @override
  String get setupComplete => 'مساحة العمل المحلية جاهزة';

  @override
  String get openNursing => 'فتح مساحة التمريض';

  @override
  String get openManager => 'فتح لوحة المدير';

  @override
  String get addNursing => 'إضافة تمريض';

  @override
  String get isManager => 'مدير أيضًا';

  @override
  String get active => 'نشط';

  @override
  String get closed => 'مغلق';

  @override
  String get open => 'مفتوح';

  @override
  String get review => 'يحتاج مراجعة';

  @override
  String get name => 'الاسم';

  @override
  String get status => 'الحالة';

  @override
  String get time => 'الوقت';

  @override
  String get details => 'التفاصيل';

  @override
  String get currency => 'ج.م';

  @override
  String get newAdvance => 'تسجيل سلفة';

  @override
  String get outstandingAdvances => 'السلف المسجلة';

  @override
  String get payrollPending => 'قواعد حساب المرتبات لم تُحدد بعد';

  @override
  String get payrollExplanation =>
      'حدد الحساب الثابت أو بالساعة أو بالحالة قبل احتساب المرتبات';

  @override
  String get advanceNote => 'السلفة النقدية تُنشئ حركة درج واحدة مرتبطة بها';

  @override
  String get saveAdvance => 'تسجيل السلفة';

  @override
  String get role => 'الدور';

  @override
  String get chiefManager => 'مدير رئيسي';

  @override
  String get financeManager => 'مدير مالي';

  @override
  String get operationsManager => 'مدير تشغيل';

  @override
  String get viewTotals => 'عرض الإجماليات والتحليلات';

  @override
  String get managePayroll => 'إدارة المرتبات والسلف';

  @override
  String get manageNursing => 'إدارة التمريض والإجراءات';

  @override
  String get editClosedShifts => 'تعديل الشيفتات المغلقة';

  @override
  String get manageManagers => 'إدارة المديرين والصلاحيات';

  @override
  String get savePermissions => 'حفظ الصلاحيات';

  @override
  String get permissionsNote =>
      'معاينة أدوار محلية؛ صلاحيات الخادم مرحلة منفصلة';

  @override
  String get conflict => 'مراجعة تعارض';

  @override
  String get noConflict => 'لا توجد تعارضات محلية';

  @override
  String get syncNote => 'العمليات تظل محلية حتى إعداد الاتصال بالخادم';

  @override
  String get retry => 'مراجعة الطابور المحلي';

  @override
  String get queue => 'العمليات المحلية المعلقة';

  @override
  String get noAudit => 'لا توجد عمليات بعد';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'الإنجليزية';

  @override
  String get savedNote => 'تم حفظ السجل على هذا الجهاز';

  @override
  String get selectStaff => 'اختر فرد التمريض';

  @override
  String get phoneHint => 'رقم للتواصل اختياري';

  @override
  String get addressHint => 'الشارع والمبنى والدور وعلامة مميزة';

  @override
  String get titleHint => 'وصف مختصر للحالة';

  @override
  String get supplyHint => 'مثل: كانولا، محلول ملحي، شاش';

  @override
  String get noShift => 'لا يوجد شيفت نشط';

  @override
  String get startNow => 'بدء الشيفت';

  @override
  String get viewHistory => 'عرض حالات الشيفت';

  @override
  String get recorded => 'مسجل';

  @override
  String get saveAndContinue => 'حفظ ومتابعة';

  @override
  String get configured => 'مُعد محليًا';

  @override
  String get emptyCatalogue => 'أضف الإجراء الأول';

  @override
  String get advanceTotal => 'إجمالي السلف';

  @override
  String get cashFormula =>
      'الرصيد الافتتاحي + مدفوعات الكاش + الوارد − الخوارج − السلف − المكافآت + فروق عدّ الدرج';

  @override
  String get showSetup => 'إعداد أول تشغيل';

  @override
  String get added => 'تمت الإضافة';

  @override
  String get noResults => 'لا توجد نتائج مطابقة';

  @override
  String get allStaff => 'كل التمريض';

  @override
  String get allTypes => 'كل أنواع الحالات';

  @override
  String get payrollUnit => 'تظهر حسابات المرتب بعد اعتماد طريقة الحساب';

  @override
  String get queueLocal => 'محلي فقط';

  @override
  String get latestActivity => 'آخر العمليات';

  @override
  String get caseAdded => 'إضافة حالة';

  @override
  String get shiftStarted => 'بدء شيفت';

  @override
  String get shiftEnded => 'إنهاء شيفت';

  @override
  String get cashAdded => 'إضافة حركة درج';

  @override
  String get staffAdded => 'إضافة تمريض';

  @override
  String get procedureAdded => 'إضافة إجراء';

  @override
  String get handoverRecorded => 'تسجيل استلام';

  @override
  String get settingsSaved => 'حفظ الإعدادات';

  @override
  String get staffJoined => 'انضمام تمريض';

  @override
  String get setupSaved => 'حفظ الإعداد المحلي';

  @override
  String get confirmJoin => 'تأكيد الانضمام';

  @override
  String get selectAtLeastOne => 'اختر فرد تمريض واحدًا على الأقل';

  @override
  String get noOpenToClose => 'لا يوجد شيفت مفتوح لإنهائه';

  @override
  String get started => 'بدأ';

  @override
  String get offlineNote => 'يستمر الحفظ المحلي بدون اتصال بالخادم';

  @override
  String get configureBackend => 'الاتصال بالخادم غير مُعد';

  @override
  String get requiredMark => 'مطلوب';

  @override
  String get previewWarning => 'معاينة محلية';

  @override
  String get selectProcedure => 'اختر الإجراء';

  @override
  String get editData => 'تعديل البيانات المحلية';

  @override
  String get close => 'إغلاق';

  @override
  String get loadingWorkspace => 'جارٍ تجهيز مساحة العمل';

  @override
  String get delete => 'حذف';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String get deleteRecord => 'حذف السجل';

  @override
  String get changeReason => 'سبب التغيير';

  @override
  String get deleteNote => 'يُسجل هذا التغيير في سجل التدقيق';

  @override
  String get recordUpdated => 'تعديل سجل';

  @override
  String get recordDeleted => 'حذف سجل';

  @override
  String get shiftArchived => 'أرشفة شيفت';

  @override
  String get supplyAdded => 'إضافة مستلزم';

  @override
  String get archiveShift => 'أرشفة الشيفت';

  @override
  String get recordNotFound => 'السجل لم يعد موجودًا';

  @override
  String get dependencyExists => 'هذا السجل مرتبط بحالات موجودة';

  @override
  String get invalidDates => 'وقت النهاية يجب أن يكون بعد البداية';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get signInSubtitle => 'افتح مساحة إدارة نيو كير';

  @override
  String get managerAccount => 'حساب المدير';

  @override
  String get managerPassword => 'كلمة مرور المدير';

  @override
  String get onlineSetupRequired =>
      'يجب إكمال الإعداد المتصل من شاشة إعداد السحابة';

  @override
  String get memberInactive => 'فرد تمريض غير نشط';

  @override
  String get viewRecord => 'عرض السجل';

  @override
  String get transactions => 'حركات الفلوس';

  @override
  String get casePayment => 'مدفوعات الحالات';

  @override
  String get dateAndTime => 'التاريخ والوقت';

  @override
  String get searchTransactions => 'ابحث بالوصف أو التمريض أو رقم المرجع';

  @override
  String get allTransactions => 'كل أنواع الحركات';

  @override
  String get allNursing => 'كل التمريض';

  @override
  String get newTransaction => 'إضافة حركة خزنة';

  @override
  String get cashIn => 'الكاش الوارد';

  @override
  String get cashOut => 'الكاش الصادر';

  @override
  String get walletReceipts => 'وارد المحفظة';

  @override
  String get netCashFlow => 'صافي حركة الكاش';

  @override
  String get transactionTotalsNote =>
      'الإجماليات حسب الفلاتر المختارة. صافي حركة الكاش لا يشمل المحفظة أو الرصيد الافتتاحي للدرج.';

  @override
  String get transactionBreakdown => 'توزيع حركات الفلوس';

  @override
  String get monthlySalary => 'المرتب الشهري';

  @override
  String get setSalary => 'تحديد مرتب التمريض';

  @override
  String get salaryRegister => 'مرتبات التمريض';

  @override
  String get salaryAfterAdvances => 'المرتب بعد سلف الفترة';

  @override
  String get salaryNote =>
      'المرتب الأساسي الشهري بعد خصم سلف الفترة. المكافآت حركات صرف كاش فعلية وتظهر منفصلة حتى لا تُحتسب مرتين.';

  @override
  String get addProcedure => 'إضافة إجراء';

  @override
  String get addSupply => 'إضافة مستلزم';

  @override
  String get accessLevels => 'مستويات الوصول';

  @override
  String get nursingAccess =>
      'تسجيل الحالات وتحصيل دفعاتها وإضافة الخوارج والسلف.';

  @override
  String get managerAccess =>
      'إدارة التمريض والمرتبات والإجراءات والسجلات والدرج، وعرض الإجماليات والتقارير. ويمكن للمدير تسجيل الحالات باسمه.';

  @override
  String get shiftOpen => 'الشيفت مفتوح';

  @override
  String get shiftClosed => 'الشيفت مغلق';

  @override
  String get addCase => 'إضافة حالة';

  @override
  String get caseType => 'نوع الحالة';

  @override
  String get cardView => 'كروت';

  @override
  String get tableView => 'جدول';

  @override
  String get award => 'مكافأة';

  @override
  String get newAward => 'إضافة مكافأة للتمريض';

  @override
  String get saveAward => 'حفظ المكافأة';

  @override
  String get awardsTotal => 'المكافآت الخارجة';

  @override
  String get salaryUpdated => 'تحديث المرتب الشهري';

  @override
  String get ended => 'انتهى';

  @override
  String get shiftTiming => 'توقيت الشيفت';

  @override
  String get checkDrawerFirst => 'راجع الدرج قبل إنهاء الشيفت';

  @override
  String get checkDrawerExplanation =>
      'اختر من عدّ الدرج، وسجّل النقدية الفعلية، ثم أكد المراجعة قبل إنهاء الشيفت.';

  @override
  String get drawerReview => 'مراجعة الدرج';

  @override
  String get drawerCheckedBy => 'من راجع وأغلق الدرج';

  @override
  String get confirmDrawerReview => 'تأكيد عدّ الدرج';

  @override
  String get drawerReviewDone =>
      'تم تأكيد مراجعة الدرج. يمكنك الآن إنهاء الشيفت.';

  @override
  String get drawerChanged => 'تغيرت بيانات الدرج. أعد العدّ وتأكيد المراجعة.';

  @override
  String get lastShiftClosed => 'إغلاق الشيفت السابق';

  @override
  String get drawerUnchecked => 'لم يُراجع';

  @override
  String get drawerMatched => 'مطابق';

  @override
  String get drawerShortage => 'عجز';

  @override
  String get drawerExcess => 'زيادة';

  @override
  String get proceduresUsed => 'الإجراءات المنفذة';

  @override
  String get selectedSupplies => 'المستلزمات المستخدمة';

  @override
  String get caseTotal => 'الإجمالي المحسوب';

  @override
  String get procedureTotal => 'إجمالي الإجراءات';

  @override
  String get supplyTotal => 'إجمالي المستلزمات';

  @override
  String get priceBreakdown => 'الحساب والمدفوع';

  @override
  String get selectItems => 'اختر العناصر';

  @override
  String get noPricedSupplies => 'لا توجد مستلزمات في الكتالوج';

  @override
  String get chooseDay => 'اختر اليوم';

  @override
  String get caseFormSubtitle =>
      'اختر الإجراءات، وأدخل إجمالي الحساب والمدفوع؛ المتبقي يتحسب تلقائيًا.';

  @override
  String get procedureRequired => 'اختر إجراء واحدًا على الأقل';

  @override
  String get itemName => 'الاسم';

  @override
  String get price => 'السعر';

  @override
  String get supplyNameHint => 'مثال: كانولا';

  @override
  String get procedureNameHint => 'مثال: تركيب محلول';

  @override
  String get priceHint => 'أدخل السعر بالجنيه المصري';

  @override
  String get shiftDetails => 'تفاصيل الشيفت';

  @override
  String get allPayments => 'كل طرق الدفع';

  @override
  String get translationUnavailable => 'غير متاح';

  @override
  String get caseUpdated => 'تم تعديل الحالة';

  @override
  String get brandName => 'NewCare';

  @override
  String get nursingCareServices => 'خدمات الرعاية التمريضية';

  @override
  String get caseRegister => 'تسجيل الحالات';

  @override
  String get caseBook => 'دفتر الحالات';

  @override
  String get catalogueTotal => 'مجموع أسعار الإجراءات';

  @override
  String get agreedPrice => 'إجمالي الحساب';

  @override
  String get paidNow => 'المدفوع عند التسجيل';

  @override
  String get remainingAmount => 'المتبقي';

  @override
  String get paidTotal => 'إجمالي المدفوع';

  @override
  String get laterPayments => 'دفعات لاحقة مسجلة';

  @override
  String get paymentHistory => 'سجل دفعات الحالة';

  @override
  String get initialPayment => 'دفعة التسجيل';

  @override
  String get receivePayment => 'تحصيل دفعة';

  @override
  String get paymentAmount => 'مبلغ الدفعة';

  @override
  String get savePayment => 'تسجيل الدفعة';

  @override
  String get casePaymentAdded => 'تم تحصيل دفعة للحالة';

  @override
  String get invalidPaymentAmount =>
      'أدخل مبلغًا صحيحًا لا يتجاوز المتبقي، ولا يقل إجمالي السعر عن المدفوع';

  @override
  String get searchCatalogue => 'ابحث واختر إجراء…';

  @override
  String get searchSupplies => 'ابحث واختر مستلزم…';

  @override
  String get caseReference => 'رقم الحالة';

  @override
  String get searchCaseBook =>
      'ابحث بالإجراء أو العنوان أو التمريض أو رقم الحالة';

  @override
  String get outstandingCases => 'حالات عليها متبقي';

  @override
  String get outstandingAllDates => 'كل الحالات التي عليها متبقي، من أي تاريخ';

  @override
  String get drawerBalance => 'رصيد الدرج الحالي';

  @override
  String get payInFull => 'دفع بالكامل';

  @override
  String get externalAdvance => 'سلفة';

  @override
  String get centerExpense => 'خوارج المركز';

  @override
  String get externalRecipient => 'اسم المستلم';

  @override
  String get recipientRequired => 'أدخل اسم الشخص المستلم';

  @override
  String get drawerHandover => 'تسليم واستلام الدرج';

  @override
  String get drawerHandoverNote =>
      'عدّ النقدية، واختر المسلِّم والمستلم. يسجل فرق العدّ بشكل مستقل ولا يُحسب إيرادًا أو ضمن الخوارج.';

  @override
  String get drawerFrom => 'المسلِّم';

  @override
  String get drawerTo => 'المستلم';

  @override
  String get drawerHolder => 'مسؤول عهدة الدرج';

  @override
  String get drawerHandoverHistory => 'سجل تسليم واستلام الدرج';

  @override
  String get confirmDrawerHandover => 'تأكيد تسليم الدرج';

  @override
  String get handoverDifferenceReason => 'ملاحظات وسبب العجز أو الزيادة إن وجد';

  @override
  String get invalidHandoverStaff =>
      'اختر المستلم الحالي للعهدة للتسليم وشخصًا آخر للاستلام';

  @override
  String get drawerHandedOver => 'تم تسليم واستلام عهدة الدرج';

  @override
  String get refreshDrawer => 'تحديث رصيد المراجعة';

  @override
  String get resetAndStartSetup => 'تصفير البيانات وبدء الإعداد';

  @override
  String get resetWorkspaceTitle => 'تأكيد تصفير البيانات';

  @override
  String get resetWorkspaceConfirm =>
      'هل أنت متأكد من تصفير كافة البيانات المحلية والبدء من جديد من شاشة الإعداد الأولية؟';

  @override
  String get confirmReset => 'تأكيد التصفير';

  @override
  String get editCasePrice => 'تعديل إجمالي الحالة';

  @override
  String get priceBelowPaid => 'لا يمكن أن يكون السعر أقل من المبلغ المحصّل';

  @override
  String get priceEditNote =>
      'تعديل إجمالي الحالة لا يغيّر الدفعات التي تم تحصيلها.';

  @override
  String get casePriceUpdated => 'تم تعديل سعر الحالة';

  @override
  String get notes => 'ملاحظات';

  @override
  String get personOutgoings => 'خوارج أشخاص';

  @override
  String get recordOutgoing => 'تسجيل الخوارج';

  @override
  String get outgoings => 'خوارج';

  @override
  String get saveOutgoing => 'حفظ الخارج';

  @override
  String get personPaymentPurpose => 'نوع الصرف';

  @override
  String get otherPersonOutgoing => 'صرف آخر';

  @override
  String get otherPerson => 'شخص آخر';

  @override
  String get personName => 'اسم الشخص';

  @override
  String get personNursingRecipient => 'مستلم المبلغ من التمريض';

  @override
  String get outgoingDescription => 'البيان';

  @override
  String get centerOutgoingHint => 'مثل: الإيجار أو الكهرباء أو المشتريات';

  @override
  String get personOutgoingHint => 'مثل: أتعاب أو رد مبلغ';

  @override
  String get incomeDescriptionHint => 'مثل: إيداع نقدي للدرج';

  @override
  String get personOutgoingHelp =>
      'اختر نوع الصرف والمستلم، ثم سجّل المبلغ. السلف ضمن خوارج الأشخاص.';

  @override
  String get centerOutgoingHelp =>
      'للإيجار والكهرباء والمشتريات وغيرها من خوارج المركز.';

  @override
  String get noOtherDrawerReceiver =>
      'يلزم وجود شخص آخر لاستلام الدرج. لا يمكن للمسلِّم استلام العهدة من نفسه.';

  @override
  String get openNavigation => 'فتح القائمة';

  @override
  String get closeNavigation => 'إغلاق القائمة';

  @override
  String get hideSidebar => 'إخفاء القائمة الجانبية';

  @override
  String get showSidebar => 'إظهار القائمة الجانبية';

  @override
  String get devicePreview => 'معاينة الأجهزة';

  @override
  String get previewDebugOnly => 'أدوات المعاينة متاحة في وضع التطوير فقط';

  @override
  String get previewDevice => 'الجهاز والمقاس';

  @override
  String get previewPlatform => 'المنصة';

  @override
  String get previewTextScale => 'حجم الخط';

  @override
  String get previewRotate => 'تدوير الشاشة';

  @override
  String get previewKeyboard => 'إظهار أو إخفاء لوحة المفاتيح';

  @override
  String get previewReset => 'المقاس الحقيقي';

  @override
  String get previewFailed => 'تعذّر تغيير المعاينة';

  @override
  String get squareMonitor => 'شاشة مربعة 1024 × 1024';

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
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get passwordTooShort => 'استخدم ٨ أحرف على الأقل';

  @override
  String get passwordUpdated => 'تم تغيير كلمة المرور';

  @override
  String get settingsSaveFailed => 'تعذّر حفظ التعديلات. حاول مرة أخرى.';

  @override
  String get navigationLabels => 'أسماء أقسام القائمة';

  @override
  String get navigationLabelsHelp =>
      'عدّل أسماء الأقسام باللغة الحالية. اترك الحقل فارغًا لاستخدام الاسم الأصلي.';

  @override
  String get restoreNavigationLabels => 'استعادة الأسماء الأصلية';

  @override
  String get navigationLabelTooLong => 'الحد الأقصى ٤٠ حرفًا';

  @override
  String get drawerStatus => 'حالة الدرج';

  @override
  String get cashDrawerHint =>
      'الرصيد يتحدّث تلقائيًا مع التحصيل بالكاش والخوارج. مدفوعات المحفظة لا تدخل الدرج.';

  @override
  String get unassignedDrawerHolder => 'لم يُحدّد مستلم للعهدة بعد';

  @override
  String get lastDrawerCheck => 'نتيجة آخر مراجعة نقدية';

  @override
  String get allPaymentMethods => 'الكل';

  @override
  String get caseAddedAt => 'تاريخ ووقت الإضافة';

  @override
  String get developerDiagnostics => 'تشخيص البيانات';

  @override
  String get diagnosticsManagerOnly => 'قسم مقفول داخل مساحة المدير';

  @override
  String get diagnosticsRefresh => 'فحص البيانات المحلية';

  @override
  String get syncNotConfigured =>
      'مزامنة البيانات لم تُفعّل بعد — لا يمكن تأكيد التطابق';

  @override
  String get diagnosticsVerificationHelp =>
      'تظهر «متطابقين» فقط بعد فحص محتوى البيانات في نفس النطاق والإصدار، مع عدم وجود عمليات معلقة أو تعارضات.';

  @override
  String get diagnosticsPending => 'عمليات محلية تنتظر الربط والمزامنة';

  @override
  String get diagnosticsDataset => 'البيانات';

  @override
  String get diagnosticsLocal => 'على الجهاز';

  @override
  String get diagnosticsCloud => 'في Supabase';

  @override
  String get diagnosticsLocalCheckedAt => 'آخر فحص محلي';

  @override
  String get diagnosticsMatched => 'متطابقين';

  @override
  String get diagnosticsDifferent => 'غير متطابقين';

  @override
  String get diagnosticsUnavailable => 'تعذر التحقق';

  @override
  String get diagnosticsPendingStatus => 'بانتظار المزامنة أو معالجة التعارض';

  @override
  String get diagnosticsPayments => 'الدفعات الإضافية';

  @override
  String get managerRequired => 'هذا القسم متاح للمدير فقط';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get previewUsername => 'اسم المستخدم المحلي الافتراضي: admin';

  @override
  String get offlineLoginHelp =>
      'بعد دخول ناجح أونلاين، يمكنك الدخول على نفس الجهاز بدون إنترنت لمدة ٧ أيام. إدارة الحسابات تحتاج اتصالًا.';

  @override
  String get offlineLoginUnavailable =>
      'يلزم أول دخول أونلاين لهذا المدير على هذا الجهاز';

  @override
  String get offlineLoginExpired =>
      'انتهت صلاحية الدخول المحلي أو تغير وقت الجهاز. اتصل بالإنترنت للتحقق.';

  @override
  String get offlineLoginLocked =>
      'الدخول المحلي مقفول مؤقتًا بعد محاولات خاطئة. حاول بعد ١٥ دقيقة.';

  @override
  String get onlineAccountChangeRequired =>
      'تعديل الحساب يتطلب اتصالًا وتحققًا من المدير';

  @override
  String get cloudFirstSetup => 'إعداد المركز وأول مدير';

  @override
  String get cloudFirstSetupHelp =>
      'أنشئ أول مدير باسم مستخدم وكلمة مرور واربط جهاز المركز. البريد للتواصل فقط، بدون رسالة تأكيد. التمريض يختار اسمه بدون حساب.';

  @override
  String get usernameHint => '٣–٣٢ حرفًا إنجليزيًا صغيرًا أو رقمًا أو _';

  @override
  String get invalidEmail => 'أدخل بريدًا إلكترونيًا صالحًا';

  @override
  String get securePasswordHint => 'كلمة المرور ٨ أحرف على الأقل';

  @override
  String get managerEmailVerificationRequired =>
      'افتح رسالة Supabase لتأكيد البريد، ثم اضغط تفعيل بعد التأكيد.';

  @override
  String get deviceEnrollmentRequired =>
      'الجهاز غير معتمد. يلزم إتمام إعداد جهاز المركز بواسطة مدير أونلاين.';

  @override
  String get cloudSetupFailed =>
      'تعذر إتمام الإعداد. تحقق من الاتصال وإعدادات الدخول، ثم أعد المحاولة. لو الحساب اتعمل بالفعل، استخدم ربط مدير موجود.';

  @override
  String get cloudMigrationsRequired =>
      'إعداد قاعدة البيانات السحابية غير مكتمل. طبّق كل migrations الخاصة بـ NewCare ثم أعد المحاولة.';

  @override
  String get managerNotProvisioned =>
      'هذا المدير غير مرتبط بمركز بعد. أنشئ المركز أولًا أو استخدم حساب المدير الأصلي.';

  @override
  String get createFirstManager => 'إنشاء المدير وإعداد المركز';

  @override
  String get activateVerifiedManager => 'ربط مدير موجود';

  @override
  String get managerAccounts => 'حسابات المديرين';

  @override
  String get managerAccountsHelp =>
      'أضف مديرًا باسم مستخدم وكلمة مرور. البريد ضمن بيانات التواصل بدون رسالة تأكيد. التمريض يضاف من صفحة التمريض بدون حساب دخول.';

  @override
  String get addManager => 'إضافة مدير';

  @override
  String get managerInvitationSent =>
      'تم إنشاء حساب المدير. يمكنه الدخول باسم المستخدم وكلمة المرور بدون تأكيد بريد.';

  @override
  String get managerCreationFailed =>
      'تعذر إنشاء حساب المدير. تحقق من اسم المستخدم والاتصال، ثم أعد المحاولة.';

  @override
  String get emailChangeVerificationHelp =>
      'البريد ضمن بيانات التواصل ويمكن تغييره بدون تأكيد. الدخول يظل باسم المستخدم.';

  @override
  String get emailConfirmationStillEnabled =>
      'يلزم إيقاف Confirm email في إعدادات Supabase لإكمال حسابات اسم المستخدم بدون رسائل تأكيد.';

  @override
  String get anonymousSignInNotEnabled =>
      'فعّل Anonymous Sign-ins في Supabase لاعتماد جهاز المركز بدون حسابات للتمريض.';

  @override
  String get localDataSyncPending =>
      'البيانات على الجهاز — المزامنة لم تُفعّل بعد';

  @override
  String get offlineManagerSession =>
      'دخول مدير محلي بدون إنترنت — تغييرات الحسابات تحتاج اتصالًا';

  @override
  String get centerBindingMismatch =>
      'هذا الجهاز مربوط بمركز آخر؛ لا يمكن دمج بيانات مركزين.';

  @override
  String get managerIdentityRefreshed => 'تحديث هوية المدير في قائمة التمريض';

  @override
  String get inventory => 'المخزن';

  @override
  String get addStockItem => 'إضافة صنف مخزن';

  @override
  String get editStockItem => 'تعديل صنف المخزن';

  @override
  String get stockQuantity => 'الكمية المتاحة';

  @override
  String get quantity => 'الكمية';

  @override
  String get archiveStockItem => 'أرشفة صنف المخزن';

  @override
  String get confirmArchive => 'هل أنت متأكد من الأرشفة';

  @override
  String get archive => 'أرشفة';

  @override
  String get laboratory => 'المعمل';

  @override
  String get addLabTest => 'إضافة تحليل';

  @override
  String get editLabTest => 'تعديل تحليل';

  @override
  String get archiveLabTest => 'أرشفة التحليل';

  @override
  String get labCatalogue => 'كتالوج التحاليل';

  @override
  String get labOrders => 'طلبات المعمل';

  @override
  String get labTotal => 'إجمالي المعمل';

  @override
  String get labRemaining => 'المتبقي';

  @override
  String get labPaidNow => 'المدفوع الآن';

  @override
  String get collectLabPayment => 'تحصيل دفعة';

  @override
  String get newLabOrder => 'طلب تحليل';

  @override
  String get selectLabTests => 'اختر التحاليل';

  @override
  String get itemsRequired => 'اختر تحليلًا واحدًا على الأقل';

  @override
  String get patientName => 'اسم المريض';

  @override
  String get patientAge => 'عمر المريض';

  @override
  String get ageUnit => 'وحدة العمر';

  @override
  String get yearUnit => 'سنوات';

  @override
  String get monthUnit => 'شهور';

  @override
  String get dayUnit => 'أيام';

  @override
  String get resultStatus => 'حالة النتيجة';

  @override
  String get resultReceived => 'تم تسليم النتيجة';

  @override
  String get resultPending => 'بانتظار النتيجة';

  @override
  String get markResultReceived => 'تأكيد تسليم النتيجة';

  @override
  String get labReceipt => 'إيصال معمل';

  @override
  String get labPayment => 'تحصيل معمل';

  @override
  String get operationalDay => 'اليوم التشغيلي';

  @override
  String get operationalDayHistory => 'سجل الأيام التشغيلية';

  @override
  String get dailyNetCash => 'صافي كاش اليوم';

  @override
  String get dailyWallet => 'محفظة اليوم';

  @override
  String get noSuppliesUsed => 'لم تُستهلك مستلزمات';

  @override
  String get usedSupplies => 'المستلزمات المستهلكة';

  @override
  String get paid => 'مدفوع';

  @override
  String get actions => 'الإجراءات';

  @override
  String get invalidStockQuantity => 'كمية المخزن غير صالحة';

  @override
  String get stockNotFound => 'صنف المخزن غير موجود';

  @override
  String get insufficientStock => 'الكمية في المخزن غير كافية';

  @override
  String get stockChanged => 'تم تعديل المخزن بواسطة عملية أخرى';

  @override
  String get labTestChanged => 'تم تعديل التحليل بواسطة عملية أخرى';

  @override
  String get duplicateName => 'الاسم موجود بالفعل';

  @override
  String get testNotFound => 'التحليل غير موجود';

  @override
  String get invalidAge => 'عمر المريض غير صالح';

  @override
  String get stalePrice => 'سعر التحليل تغيّر في الكتالوج';

  @override
  String get orderNotFound => 'طلب المعمل غير موجود';

  @override
  String get stockSaved => 'تم حفظ صنف المخزن';

  @override
  String get stockArchived => 'تم أرشفة صنف المخزن';

  @override
  String get labTestSaved => 'تم حفظ التحليل';

  @override
  String get labTestArchived => 'تم أرشفة التحليل';

  @override
  String get labOrderAdded => 'تم تسجيل طلب المعمل';

  @override
  String get labPaymentAdded => 'تم تحصيل دفعة المعمل';

  @override
  String get labReceivedUpdated => 'تم تحديث حالة تسليم النتيجة';

  @override
  String get noLabOrders => 'لا توجد طلبات معمل حتى الآن';

  @override
  String get noLabTests => 'لا توجد تحاليل مسجلة في الكتالوج حتى الآن';

  @override
  String get noStockItems => 'لا توجد أصناف في المخزن حتى الآن';
}
