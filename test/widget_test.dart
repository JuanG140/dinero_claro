import 'package:flutter_test/flutter_test.dart';

import 'package:dinero_claro/models/gasto.dart';
import 'package:dinero_claro/utils/formato.dart';

void main() {
  test('formatoPesos pone puntos de miles', () {
    expect(formatoPesos(1234567), '\$1.234.567');
    expect(formatoPesos(500), '\$500');
  });

  test('Un gasto pasa a fila de SQLite y vuelve igual', () {
    final gasto = Gasto(
      id: 3,
      descripcion: 'Spotify',
      montoOriginal: 5.99,
      moneda: 'USD',
      tasa: 4000,
      categoria: 'Suscripciones',
      fecha: DateTime(2026, 11, 24),
    );

    final copia = Gasto.fromMap(gasto.toMap());

    expect(copia.id, 3);
    expect(copia.descripcion, 'Spotify');
    expect(copia.fecha, gasto.fecha);
    expect(copia.montoCop, closeTo(23960, 0.01));
  });
}
