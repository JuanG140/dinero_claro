import 'package:material_ui/material_ui.dart';

import '../models/gasto.dart';
import '../utils/formato.dart';
import '../widgets/tarjeta_gasto.dart';
import 'detalle_gasto_screen.dart';
import 'nuevo_gasto_screen.dart';
import 'tasas_screen.dart';

/// Pantalla 1: total gastado en el mes y lista de gastos.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  // Por ahora los gastos viven en memoria: se pierden al cerrar la app.
  // En la etapa 3 se guardan en SQLite.
  final List<Gasto> _gastos = [];

  /// Suma en pesos de los gastos del mes actual.
  double get _totalMes {
    final ahora = DateTime.now();
    return _gastos
        .where((g) => g.fecha.year == ahora.year && g.fecha.month == ahora.month)
        .fold<double>(0, (suma, g) => suma + g.montoCop);
  }

  /// Abre el formulario y espera el gasto que devuelve con Navigator.pop.
  Future<void> _abrirNuevoGasto() async {
    final nuevo = await Navigator.push<Gasto>(
      context,
      MaterialPageRoute(builder: (_) => const NuevoGastoScreen()),
    );
    if (nuevo == null) return; // El usuario volvió sin guardar.
    setState(() => _gastos.insert(0, nuevo));
  }

  /// Envía el gasto elegido a la pantalla de detalle (el dato que viaja).
  /// Si allá lo borran, la pantalla devuelve true.
  Future<void> _abrirDetalle(Gasto gasto) async {
    final borrado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DetalleGastoScreen(gasto: gasto)),
    );
    if (borrado == true) {
      setState(() => _gastos.remove(gasto));
    }
  }

  void _abrirTasas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TasasScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DineroClaro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            tooltip: 'Tasas del día',
            onPressed: _abrirTasas,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Card(
              margin: const EdgeInsets.all(16),
              color: tema.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gastado este mes'),
                    const SizedBox(height: 4),
                    Text(
                      formatoPesos(_totalMes),
                      style: tema.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _gastos.isEmpty
                ? const Center(
                    child: Text(
                      'Todavía no tienes gastos.\nToca + para agregar el primero.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _gastos.length,
                    itemBuilder: (context, i) => TarjetaGasto(
                      gasto: _gastos[i],
                      onTap: () => _abrirDetalle(_gastos[i]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirNuevoGasto,
        tooltip: 'Nuevo gasto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
