import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:dinero_claro/models/gasto.dart';
import 'package:dinero_claro/models/tasas_cambio.dart';
import 'package:dinero_claro/services/api_tasas.dart';
import 'package:dinero_claro/utils/formato.dart';

/// Respuesta de ejemplo con la misma forma que la de la API real.
const respuestaEjemplo = {
  'result': 'success',
  'base_code': 'COP',
  'time_last_update_unix': 1795564800,
  'rates': {'COP': 1, 'USD': 0.00025, 'EUR': 0.0002},
};

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

  test('TasasCambio lee el JSON y calcula pesos por moneda', () {
    final tasas = TasasCambio.fromJson(respuestaEjemplo);

    expect(tasas.base, 'COP');
    expect(tasas.pesosPor('USD'), closeTo(4000, 0.001));
    expect(tasas.pesosPor('EUR'), closeTo(5000, 0.001));
  });

  test('ApiTasas devuelve las tasas cuando la API responde bien', () async {
    final cliente = MockClient(
      (_) async => http.Response(jsonEncode(respuestaEjemplo), 200),
    );

    final tasas = await ApiTasas(cliente: cliente).obtenerTasas();

    expect(tasas.pesosPor('USD'), closeTo(4000, 0.001));
  });

  test('ApiTasas lanza ErrorApi cuando la API falla', () async {
    final cliente = MockClient((_) async => http.Response('caída', 500));

    await expectLater(
      ApiTasas(cliente: cliente).obtenerTasas(),
      throwsA(isA<ErrorApi>()),
    );
  });
}
