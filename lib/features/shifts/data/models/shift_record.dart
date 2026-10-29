class ShiftRecord {
  const ShiftRecord({
    required this.id,
    required this.openedAt,
    required this.memberIds,
    required this.openingMinor,
    this.closedAt,
    this.note = '',
    this.archived = false,
    this.drawerCheckedBy,
    this.drawerCheckedAt,
    this.closingCountedMinor,
    this.closingExpectedMinor,
    this.closingDifferenceReason = '',
  });
  final String id, note;
  final DateTime openedAt;
  final DateTime? closedAt;
  final List<String> memberIds;
  final int openingMinor;
  final bool archived;
  final String? drawerCheckedBy;
  final DateTime? drawerCheckedAt;
  final int? closingCountedMinor, closingExpectedMinor;
  final String closingDifferenceReason;
  int? get closingDifferenceMinor =>
      closingCountedMinor == null || closingExpectedMinor == null
      ? null
      : closingCountedMinor! - closingExpectedMinor!;
  String get drawerStatusKey => switch (closingDifferenceMinor) {
    null => 'drawerUnchecked',
    0 => 'drawerMatched',
    < 0 => 'drawerShortage',
    _ => 'drawerExcess',
  };
  bool get isOpen => closedAt == null && !archived;
  ShiftRecord copyWith({
    List<String>? memberIds,
    DateTime? closedAt,
    String? note,
    bool? archived,
    String? drawerCheckedBy,
    DateTime? drawerCheckedAt,
    int? closingCountedMinor,
    int? closingExpectedMinor,
    String? closingDifferenceReason,
  }) => ShiftRecord(
    id: id,
    openedAt: openedAt,
    memberIds: memberIds ?? this.memberIds,
    openingMinor: openingMinor,
    closedAt: closedAt ?? this.closedAt,
    note: note ?? this.note,
    archived: archived ?? this.archived,
    drawerCheckedBy: drawerCheckedBy ?? this.drawerCheckedBy,
    drawerCheckedAt: drawerCheckedAt ?? this.drawerCheckedAt,
    closingCountedMinor: closingCountedMinor ?? this.closingCountedMinor,
    closingExpectedMinor: closingExpectedMinor ?? this.closingExpectedMinor,
    closingDifferenceReason:
        closingDifferenceReason ?? this.closingDifferenceReason,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'opened': openedAt.toIso8601String(),
    'closed': closedAt?.toIso8601String(),
    'members': memberIds,
    'opening': openingMinor,
    'note': note,
    'archived': archived,
    'drawerCheckedBy': drawerCheckedBy,
    'drawerCheckedAt': drawerCheckedAt?.toIso8601String(),
    'closingCounted': closingCountedMinor,
    'closingExpected': closingExpectedMinor,
    'closingDifferenceReason': closingDifferenceReason,
  };
  factory ShiftRecord.fromJson(Map<String, dynamic> j) => ShiftRecord(
    id: j['id'] as String,
    openedAt: DateTime.parse(j['opened'] as String),
    memberIds: List<String>.from(j['members'] as List),
    openingMinor: j['opening'] as int,
    closedAt: j['closed'] == null
        ? null
        : DateTime.parse(j['closed'] as String),
    note: j['note'] as String? ?? '',
    archived: j['archived'] as bool? ?? false,
    drawerCheckedBy: j['drawerCheckedBy'] as String?,
    drawerCheckedAt: j['drawerCheckedAt'] == null
        ? null
        : DateTime.parse(j['drawerCheckedAt'] as String),
    closingCountedMinor: j['closingCounted'] as int?,
    closingExpectedMinor: j['closingExpected'] as int?,
    closingDifferenceReason: j['closingDifferenceReason'] as String? ?? '',
  );
}
