import 'package:material_ui/material_ui.dart';

/// Categorías disponibles para clasificar un gasto.
const List<String> categorias = [
  'Comida',
  'Transporte',
  'Estudio',
  'Suscripciones',
  'Ocio',
  'Otros',
];

/// Monedas en las que se puede registrar un gasto: código y nombre.
const Map<String, String> monedas = {
  'COP': 'Peso colombiano',
  'USD': 'Dólar estadounidense',
  'EUR': 'Euro',
};

/// Devuelve el ícono que representa cada categoría en la lista de gastos.
IconData iconoCategoria(String categoria) {
  return switch (categoria) {
    'Comida' => Icons.restaurant,
    'Transporte' => Icons.directions_bus,
    'Estudio' => Icons.school,
    'Suscripciones' => Icons.subscriptions,
    'Ocio' => Icons.sports_esports,
    _ => Icons.receipt_long,
  };
}
