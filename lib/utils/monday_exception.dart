class MondayRateLimitException implements Exception {
  final String message;
  MondayRateLimitException([
    this.message = 'Servidor saturado (Monday). Intenta nuevamente en unos segundos.',
  ]);

  @override
  String toString() => message;
}
