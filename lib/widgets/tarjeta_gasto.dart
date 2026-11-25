import 'package:material_ui/material_ui.dart';

import '../models/gasto.dart';
import '../utils/constantes.dart';
import '../utils/formato.dart';

/// Tarjeta reutilizable que muestra un gasto en la lista de la pantalla Inicio.
class TarjetaGasto extends StatelessWidget {
  final Gasto gasto;
  final VoidCallback onTap;

  const TarjetaGasto({super.key, required this.gasto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(child: Icon(iconoCategoria(gasto.categoria))),
        title: Text(gasto.descripcion),
        subtitle: Text('${gasto.categoria} · ${formatoFecha(gasto.fecha)}'),
        trailing: Text(
          formatoPesos(gasto.montoCop),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: onTap,
      ),
    );
  }
}
