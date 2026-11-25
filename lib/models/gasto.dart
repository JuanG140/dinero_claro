/// Representa un gasto que registra el estudiante.
///
/// Se guarda el monto en la moneda original y la tasa usada para pasarlo
/// a pesos, así el valor en pesos no cambia aunque el dólar cambie después.
class Gasto {
  /// Identificador en la base de datos. Es null mientras no se ha guardado.
  final int? id;
  final String descripcion;

  /// Monto tal como lo pagó el usuario, en su moneda original.
  final double montoOriginal;

  /// Código de la moneda: 'COP', 'USD' o 'EUR'.
  final String moneda;

  /// Cuántos pesos vale 1 unidad de [moneda]. Si la moneda es COP, vale 1.
  final double tasa;
  final String categoria;
  final DateTime fecha;

  const Gasto({
    this.id,
    required this.descripcion,
    required this.montoOriginal,
    required this.moneda,
    required this.tasa,
    required this.categoria,
    required this.fecha,
  });

  /// El gasto convertido a pesos colombianos.
  double get montoCop => montoOriginal * tasa;
}
