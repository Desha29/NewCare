class NursingMember {
  const NursingMember({
    required this.id,
    required this.name,
    this.isManager = false,
    this.active = true,
  });
  final String id, name;
  final bool isManager, active;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isManager': isManager,
    'active': active,
  };
  factory NursingMember.fromJson(Map<String, dynamic> j) => NursingMember(
    id: j['id'] as String,
    name: j['name'] as String,
    isManager: j['isManager'] as bool? ?? false,
    active: j['active'] as bool? ?? true,
  );
}
