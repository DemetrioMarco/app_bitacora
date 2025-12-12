class AppUser {
  final int? id;
  final String username;
  final String role;
  final String pass;

  AppUser({
    this.id,
    required this.username,
    required this.role,
    required this.pass
  });

  Map<String, dynamic> toMap() => {
    'id':id,
    'username': username,
    'role': role,
    'pass': pass
  };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
    id:m['id'] as int?,
    username: m['username'] as String,
    role: m['role'] as String,
    pass: m['pass'] as String
  );
}