class NursingMember {
  const NursingMember({
    required this.id,
    required this.name,
    this.isManager = false,
    this.active = true,
    this.salaryMinor = 0,
    this.phone = '',
  });
  final String id, name;
  final bool isManager, active;
  final int salaryMinor;
  final String phone;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isManager': isManager,
    'active': active,
    'salary': salaryMinor,
    'phone': phone,
  };
  factory NursingMember.fromJson(Map<String, dynamic> j) => NursingMember(
    id: j['id'] as String,
    name: j['name'] as String,
    isManager: j['isManager'] as bool? ?? false,
    active: j['active'] as bool? ?? true,
    salaryMinor: j['salary'] as int? ?? 0,
    phone: j['phone'] as String? ?? '',
  );
}
