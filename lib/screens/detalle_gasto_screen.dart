import 'package:material_ui/material_ui.dart';

import '../models/gasto.dart';
import '../utils/formato.dart';

/// Pantalla 3: detalle de un gasto. Recibe el [Gasto] desde Inicio
/// por el constructor: ese es el dato que viaja entre pantallas.
class DetalleGastoScreen extends StatelessWidget {
  final Gasto gasto;

  const DetalleGastoScreen({super.key, required this.gasto});

  /// Pide confirmación y, si el usuario acepta, regresa a Inicio con true.
  Future<void> _confirmarBorrado(BuildContext context) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('¿Borrar este gasto?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmado == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final montoOriginal = gasto.moneda == 'COP'
        ? formatoPesos(gasto.montoOriginal)
        : '${gasto.montoOriginal.toStringAsFixed(2)} ${gasto.moneda}';

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del gasto')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            gasto.descripcion,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _FilaDato(etiqueta: 'Categoría', valor: gasto.categoria),
          _FilaDato(etiqueta: 'Fecha', valor: formatoFecha(gasto.fecha)),
          _FilaDato(etiqueta: 'Monto original', valor: montoOriginal),
          if (gasto.moneda != 'COP')
            _FilaDato(
              etiqueta: 'Tasa usada (1 ${gasto.moneda})',
              valor: formatoPesos(gasto.tasa),
            ),
          _FilaDato(
            etiqueta: 'Equivalente en pesos',
            valor: formatoPesos(gasto.montoCop),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _confirmarBorrado(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Borrar gasto'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}

/// Fila reutilizable de etiqueta y valor.
class _FilaDato extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _FilaDato({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(etiqueta),
      trailing: Text(
        valor,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
