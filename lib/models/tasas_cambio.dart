/// Tasas de cambio que devuelve la API de ExchangeRate-API.
///
/// Se piden con base en pesos colombianos (COP), así una sola consulta trae
/// el dólar y el euro. La API responde cuánto vale 1 peso en cada moneda
/// (por ejemplo 1 COP = 0.00025 USD), y [pesosPor] lo invierte para saber
/// cuántos pesos vale 1 dólar (1 / 0.00025 = 4000).
class TasasCambio {
  /// Moneda base de la consulta (COP).
  final String base;

  /// Momento en que la API actualizó las tasas por última vez.
  final DateTime actualizacion;

  /// Cuánto vale 1 unidad de [base] en cada moneda: {'USD': 0.00025, ...}.
  final Map<String, double> tasas;

  const TasasCambio({
    required this.base,
    required this.actualizacion,
    required this.tasas,
  });

  /// Convierte el JSON de la API en un objeto de Dart.
  ///
  /// Ejemplo de respuesta (resumido):
  /// { "result": "success", "base_code": "COP",
  ///   "time_last_update_unix": 1795564800,
  ///   "rates": { "COP": 1, "USD": 0.00025, "EUR": 0.00022, ... } }
  factory TasasCambio.fromJson(Map<String, dynamic> json) {
    final rates = json['rates'] as Map<String, dynamic>;
    final segundos = json['time_last_update_unix'] as int;

    return TasasCambio(
      base: json['base_code'] as String,
      actualizacion: DateTime.fromMillisecondsSinceEpoch(segundos * 1000),
      tasas: rates.map(
        (moneda, valor) => MapEntry(moneda, (valor as num).toDouble()),
      ),
    );
  }

  /// Cuántos pesos vale 1 unidad de [moneda].
  double pesosPor(String moneda) {
    final tasa = tasas[moneda];
    if (tasa == null || tasa == 0) {
      throw ArgumentError('No hay tasa para $moneda');
    }
    return 1 / tasa;
  }
}
