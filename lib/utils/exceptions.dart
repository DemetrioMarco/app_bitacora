abstract class AppException implements Exception {
  final String message;
  final String prefix;
  final String code;
  final Object? cause;

  const AppException(
    this.message, {
    required this.prefix,
    required this.code,
    this.cause,
  });

  /// Mensaje amigable para mostrar al usuario.
  String get userMessage => message;

  /// Mensaje técnico para debug/logs.
  String get technicalMessage =>
      cause == null ? '$prefix[$code]: $message' : '$prefix[$code]: $message | cause: $cause';

  @override
  String toString() => technicalMessage;
}

/// Error de autenticación: credenciales inválidas, usuario no autorizado, etc.
class AuthException extends AppException {
  const AuthException({
    String message = 'Credenciales inválidas',
    Object? cause,
  }) : super(
          message,
          prefix: 'Autenticación',
          code: 'AUTH_ERROR',
          cause: cause,
        );
}

/// Error de red/conectividad: sin internet, DNS, socket, etc.
class NetworkException extends AppException {
  const NetworkException({
    String message = 'Sin conexión a internet',
    Object? cause,
  }) : super(
          message,
          prefix: 'Conexión',
          code: 'NETWORK_ERROR',
          cause: cause,
        );
}

/// Error del servidor: respuestas 5xx o fallos internos del backend.
class ServerException extends AppException {
  const ServerException({
    String message = 'Error en el servidor',
    Object? cause,
  }) : super(
          message,
          prefix: 'Servidor',
          code: 'SERVER_ERROR',
          cause: cause,
        );
}

/// Error de tiempo de espera en una petición.
/// Se evita el nombre TimeoutException para no chocar con dart:async.
class RequestTimeoutException extends AppException {
  const RequestTimeoutException({
    String message = 'Tiempo de espera agotado',
    Object? cause,
  }) : super(
          message,
          prefix: 'Timeout',
          code: 'TIMEOUT_ERROR',
          cause: cause,
        );
}

/// Error de almacenamiento local/seguro.
class StorageException extends AppException {
  const StorageException({
    String message = 'Error de almacenamiento',
    Object? cause,
  }) : super(
          message,
          prefix: 'Storage',
          code: 'STORAGE_ERROR',
          cause: cause,
        );
}

/// Error de formato o respuesta inesperada del backend.
class FormatAppException extends AppException {
  const FormatAppException({
    String message = 'Respuesta inválida del servidor',
    Object? cause,
  }) : super(
          message,
          prefix: 'Formato',
          code: 'FORMAT_ERROR',
          cause: cause,
        );
}

/// Error genérico de sesión expirada o inválida.
class SessionExpiredException extends AppException {
  const SessionExpiredException({
    String message = 'Tu sesión expiró, vuelve a iniciar sesión',
    Object? cause,
  }) : super(
          message,
          prefix: 'Sesión',
          code: 'SESSION_EXPIRED',
          cause: cause,
        );
}
