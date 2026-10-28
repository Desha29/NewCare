class ShiftRecord {
  const ShiftRecord({required this.id, required this.openedAt, required this.memberIds, required this.openingMinor, this.closedAt, this.note=''});
  final String id, note;
  final DateTime openedAt;
  final DateTime? closedAt;
  final List<String> memberIds;
  final int openingMinor;
  bool get isOpen => closedAt == null;
  ShiftRecord copyWith({List<String>? memberIds, DateTime? closedAt, String? note}) => ShiftRecord(id:id, openedAt:openedAt, memberIds:memberIds ?? this.memberIds, openingMinor:openingMinor, closedAt:closedAt ?? this.closedAt, note:note ?? this.note);
  Map<String, dynamic> toJson() => {'id':id, 'opened':openedAt.toIso8601String(), 'closed':closedAt?.toIso8601String(), 'members':memberIds, 'opening':openingMinor, 'note':note};
  factory ShiftRecord.fromJson(Map<String, dynamic> j) => ShiftRecord(id:j['id'] as String, openedAt:DateTime.parse(j['opened'] as String), memberIds:List<String>.from(j['members'] as List), openingMinor:j['opening'] as int, closedAt:j['closed']==null?null:DateTime.parse(j['closed'] as String), note:j['note'] as String? ?? '');
}

