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

  /// Convierte el gasto en una fila para la tabla `gastos` de SQLite.
  /// La fecha se guarda como texto ISO 8601 porque SQLite no tiene tipo fecha.
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'descripcion': descripcion,
      'monto_original': montoOriginal,
      'moneda': moneda,
      'tasa': tasa,
      'categoria': categoria,
      'fecha': fecha.toIso8601String(),
    };
  }

  /// Crea un gasto a partir de una fila leída de SQLite.
  factory Gasto.fromMap(Map<String, Object?> fila) {
    return Gasto(
      id: fila['id'] as int?,
      descripcion: fila['descripcion'] as String,
      montoOriginal: (fila['monto_original'] as num).toDouble(),
      moneda: fila['moneda'] as String,
      tasa: (fila['tasa'] as num).toDouble(),
      categoria: fila['categoria'] as String,
      fecha: DateTime.parse(fila['fecha'] as String),
    );
  }

  /// Copia el gasto cambiando el id (se usa al recibir el id de la base).
  Gasto copyWith({int? id}) {
    return Gasto(
      id: id ?? this.id,
      descripcion: descripcion,
      montoOriginal: montoOriginal,
      moneda: moneda,
      tasa: tasa,
      categoria: categoria,
      fecha: fecha,
    );
  }
}
