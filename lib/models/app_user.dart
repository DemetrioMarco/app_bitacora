class AppUser {
  final int id;
  final String nombre;
  final String email;
  final String rol;
  final bool? enabled;

  AppUser({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.enabled,
  });

  Map<String, dynamic> toMap() => {
    'id':id,
    'nombre': nombre,
    'email': email,
    'role': rol,
    'enabled':enabled
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        email: json['email'] as String,
        rol: json['rol'] as String,
        enabled: json['enabled'] as bool?,
      );

  // Compatibilidad con el código existente
  String get role => rol;
  String get username => email;
}