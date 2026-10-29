class DrawerHandover {
  const DrawerHandover({
    required this.id,
    required this.fromStaffId,
    required this.toStaffId,
    required this.expectedMinor,
    required this.countedMinor,
    required this.at,
    this.note = '',
  });
  final String id, fromStaffId, toStaffId, note;
  final int expectedMinor, countedMinor;
  final DateTime at;
  int get differenceMinor => countedMinor - expectedMinor;
  String get statusKey => differenceMinor == 0
      ? 'drawerMatched'
      : differenceMinor < 0
      ? 'drawerShortage'
      : 'drawerExcess';
  Map<String, dynamic> toJson() => {
    'id': id,
    'from': fromStaffId,
    'to': toStaffId,
    'expected': expectedMinor,
    'counted': countedMinor,
    'at': at.toIso8601String(),
    'note': note,
  };
  factory DrawerHandover.fromJson(Map<String, dynamic> j) => DrawerHandover(
    id: j['id'] as String,
    fromStaffId: j['from'] as String,
    toStaffId: j['to'] as String,
    expectedMinor: j['expected'] as int,
    countedMinor: j['counted'] as int,
    at: DateTime.parse(j['at'] as String),
    note: j['note'] as String? ?? '',
  );
}
