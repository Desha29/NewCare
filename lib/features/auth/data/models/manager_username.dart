abstract final class ManagerUsername {
  static String normalize(String value) => value.trim().toLowerCase();
  static bool valid(String value) =>
      RegExp(r'^[a-z0-9_]{3,32}$').hasMatch(normalize(value));
  // A stable internal Auth identifier. The manager's editable contact email is
  // a separate profile field, never used to deliver verification messages.
  static String authAddress(String value) {
    if (!valid(value)) throw ArgumentError('Invalid username');
    return '${normalize(value)}@accounts.newcare.invalid';
  }
}
