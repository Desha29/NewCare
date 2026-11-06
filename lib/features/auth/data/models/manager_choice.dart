/// Public-to-the-enrolled-device login label, without email or permissions.
class ManagerChoice {
  const ManagerChoice({
    required this.id,
    required this.username,
    required this.name,
  });
  final String id, username, name;
  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'name': name,
  };
  factory ManagerChoice.fromJson(Map<String, dynamic> json) => ManagerChoice(
    id: json['id'] as String,
    username: json['username'] as String,
    name: json['name'] as String,
  );
}
