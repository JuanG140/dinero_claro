import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/tasas_cambio.dart';

/// Error con un mensaje listo para mostrarle al usuario.
class ErrorApi implements Exception {
  final String mensaje;

  const ErrorApi(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Servicio que consulta las tasas de cambio en ExchangeRate-API.
///
/// Usa el punto de acceso abierto, que no necesita clave (así no hay
/// ninguna clave privada que proteger en el repositorio).
class ApiTasas {
  /// El cliente se puede cambiar en las pruebas por uno simulado.
  ApiTasas({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  /// Instancia que usa toda la app, para compartir la caché.
  static final ApiTasas instancia = ApiTasas();

  static final Uri _url = Uri.parse('https://open.er-api.com/v6/latest/COP');
  static const Duration _tiempoEspera = Duration(seconds: 10);

  /// La API actualiza una vez al día, así que no hace falta preguntar en
  /// cada pantalla: se reutiliza la última respuesta durante una hora.
  static const Duration _vigenciaCache = Duration(hours: 1);

  final http.Client _cliente;
  TasasCambio? _cache;
  DateTime? _horaCache;

  /// Devuelve las tasas. Si [forzar] es true, ignora la caché.
  Future<TasasCambio> obtenerTasas({bool forzar = false}) async {
    final cache = _cache;
    final horaCache = _horaCache;
    if (!forzar &&
        cache != null &&
        horaCache != null &&
        DateTime.now().difference(horaCache) < _vigenciaCache) {
      return cache;
    }

    final tasas = await _consultar();
    _cache = tasas;
    _horaCache = DateTime.now();
    return tasas;
  }

  /// Hace la petición HTTP y traduce cada falla a un [ErrorApi].
  Future<TasasCambio> _consultar() async {
    try {
      final respuesta = await _cliente.get(_url).timeout(_tiempoEspera);

      if (respuesta.statusCode != 200) {
        throw ErrorApi(
          'El servicio de tasas respondió con error ${respuesta.statusCode}.',
        );
      }

      final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
      if (datos['result'] != 'success') {
        throw const ErrorApi('El servicio de tasas no devolvió datos válidos.');
      }

      return TasasCambio.fromJson(datos);
    } on ErrorApi {
      rethrow;
    } on TimeoutException {
      throw const ErrorApi(
        'La consulta tardó demasiado. Revisa tu conexión e intenta de nuevo.',
      );
    } on FormatException {
      throw const ErrorApi('La respuesta del servicio no se pudo leer.');
    } catch (_) {
      throw const ErrorApi(
        'No hay conexión a internet o el servicio no responde.',
      );
    }
  }
}
