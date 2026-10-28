import '../../../staff/data/models/nursing_member.dart';
import '../../../catalogue/data/models/procedure.dart';
import '../../../cases/data/models/case_record.dart';
import '../../../shifts/data/models/shift_record.dart';
import '../models/workspace_snapshot.dart';

WorkspaceSnapshot demoWorkspace() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day, 8);
  return WorkspaceSnapshot(
    setupDone: true,
    managerName: 'مصطفى عمرو',
    managerEmail: 'manager@newcare.example',
    openingMinor: 215000,
    staff: const [
      NursingMember(id: 'n1', name: 'محمود أحمد'),
      NursingMember(id: 'n2', name: 'مصطفى عمرو', isManager: true),
      NursingMember(id: 'n3', name: 'سارة محمد'),
    ],
    procedures: const [
      Procedure(
        id: 'p1',
        nameAr: 'تركيب محلول',
        nameEn: 'IV infusion',
        priceMinor: 25000,
      ),
      Procedure(
        id: 'p2',
        nameAr: 'تغيير غيار',
        nameEn: 'Dressing change',
        priceMinor: 18000,
      ),
      Procedure(
        id: 'p3',
        nameAr: 'حقن عضل',
        nameEn: 'IM injection',
        priceMinor: 5000,
      ),
      Procedure(
        id: 'p4',
        nameAr: 'خياطة جرح',
        nameEn: 'Suturing',
        priceMinor: 35000,
      ),
    ],
    shifts: [
      ShiftRecord(
        id: 'shift-demo',
        openedAt: start,
        memberIds: const ['n1', 'n2'],
        openingMinor: 215000,
      ),
    ],
    cases: List.generate(
      12,
      (i) => CaseRecord(
        id: 'case-demo-$i',
        shiftId: 'shift-demo',
        staffId: i % 3 == 0 ? 'n2' : 'n1',
        title: i % 3 == 0 ? 'تغيير غيار' : 'تركيب محلول',
        procedureId: i % 3 == 0 ? 'p2' : 'p1',
        supplies: const ['1 × cannula', '1 × saline'],
        amountMinor: i % 3 == 0 ? 18000 : 25000,
        payment: i % 3 == 0 ? PaymentMethod.wallet : PaymentMethod.cash,
        location: i % 3 == 0 ? CaseLocation.outside : CaseLocation.inside,
        createdAt: start.add(Duration(minutes: 10 + i * 8)),
        address: i % 3 == 0 ? 'شارع النصر، عمارة ١٢، الدور الثاني' : '',
      ),
    ),
    permissions: const {
      'chiefManager': [
        'viewTotals',
        'managePayroll',
        'manageNursing',
        'editClosedShifts',
        'manageManagers',
      ],
      'financeManager': ['viewTotals', 'managePayroll'],
      'operationsManager': ['manageNursing'],
    },
  );
}
