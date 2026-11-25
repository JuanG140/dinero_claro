/// Convierte un número en texto de pesos colombianos: 1234567 -> "$1.234.567".
///
/// Se redondea a pesos enteros y se ponen puntos cada tres cifras,
/// recorriendo los dígitos de izquierda a derecha.
String formatoPesos(double valor) {
  final entero = valor.round();
  final digitos = entero.abs().toString();
  final buffer = StringBuffer();

  for (int i = 0; i < digitos.length; i++) {
    buffer.write(digitos[i]);
    final faltan = digitos.length - i - 1;
    if (faltan > 0 && faltan % 3 == 0) {
      buffer.write('.');
    }
  }

  final signo = entero < 0 ? '-' : '';
  return '$signo\$$buffer';
}

/// Convierte una fecha en texto dd/mm/aaaa.
String formatoFecha(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year}';
}
