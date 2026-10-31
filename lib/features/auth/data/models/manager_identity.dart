class ManagerIdentity {
  const ManagerIdentity({
    required this.id,
    required this.centerId,
    required this.username,
    required this.name,
    required this.email,
    required this.manageAccounts,
    required this.viewDiagnostics,
  });
  final String id, centerId, username, name, email;
  final bool manageAccounts, viewDiagnostics;

  Map<String, Object?> toJson() => {
    'id': id,
    'centerId': centerId,
    'username': username,
    'name': name,
    'email': email,
    'manageAccounts': manageAccounts,
    'viewDiagnostics': viewDiagnostics,
  };
  factory ManagerIdentity.fromJson(Map<String, dynamic> json) =>
      ManagerIdentity(
        id: json['id'] as String,
        centerId: json['centerId'] as String,
        username: json['username'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        manageAccounts: json['manageAccounts'] as bool,
        viewDiagnostics: json['viewDiagnostics'] as bool,
      );
}

class ManagerAuthException implements Exception {
  const ManagerAuthException(this.code);
  final String code;
}
