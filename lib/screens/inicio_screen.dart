import 'package:material_ui/material_ui.dart';

import '../models/gasto.dart';
import '../services/base_datos.dart';
import '../utils/formato.dart';
import '../widgets/tarjeta_gasto.dart';
import 'detalle_gasto_screen.dart';
import 'nuevo_gasto_screen.dart';
import 'tasas_screen.dart';

/// Pantalla 1: total gastado en el mes y lista de gastos guardados.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _baseDatos = BaseDatos.instancia;

  List<Gasto> _gastos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Al abrir la app se leen los gastos que quedaron guardados en SQLite.
    _cargarGastos();
  }

  Future<void> _cargarGastos() async {
    try {
      final gastos = await _baseDatos.obtenerGastos();
      if (!mounted) return;
      setState(() {
        _gastos = gastos;
        _cargando = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = 'No se pudieron cargar tus gastos.';
      });
    }
  }

  void _reintentar() {
    setState(() {
      _cargando = true;
      _error = null;
    });
    _cargarGastos();
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  /// Suma en pesos de los gastos del mes actual.
  double get _totalMes {
    final ahora = DateTime.now();
    return _gastos
        .where((g) => g.fecha.year == ahora.year && g.fecha.month == ahora.month)
        .fold<double>(0, (suma, g) => suma + g.montoCop);
  }

  /// Abre el formulario, espera el gasto que devuelve con Navigator.pop
  /// y lo guarda en SQLite.
  Future<void> _abrirNuevoGasto() async {
    final nuevo = await Navigator.push<Gasto>(
      context,
      MaterialPageRoute(builder: (_) => const NuevoGastoScreen()),
    );
    if (nuevo == null) return; // El usuario volvió sin guardar.

    try {
      final guardado = await _baseDatos.insertarGasto(nuevo);
      if (!mounted) return;
      setState(() => _gastos.insert(0, guardado));
    } catch (_) {
      if (!mounted) return;
      _mostrarMensaje('No se pudo guardar el gasto. Intenta de nuevo.');
    }
  }

  /// Envía el gasto elegido a la pantalla de detalle (el dato que viaja).
  /// Si allá lo borran, la pantalla devuelve true y se borra de SQLite.
  Future<void> _abrirDetalle(Gasto gasto) async {
    final borrado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => DetalleGastoScreen(gasto: gasto)),
    );
    if (borrado != true || gasto.id == null) return;

    try {
      await _baseDatos.borrarGasto(gasto.id!);
      if (!mounted) return;
      setState(() => _gastos.remove(gasto));
      _mostrarMensaje('Gasto borrado');
    } catch (_) {
      if (!mounted) return;
      _mostrarMensaje('No se pudo borrar el gasto.');
    }
  }

  void _abrirTasas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TasasScreen()),
    );
  }

  /// Muestra la lista según el estado: cargando, error, vacía o con datos.
  Widget _construirLista() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 8),
            FilledButton(onPressed: _reintentar, child: const Text('Reintentar')),
          ],
        ),
      );
    }
    if (_gastos.isEmpty) {
      return const Center(
        child: Text(
          'Todavía no tienes gastos.\nToca + para agregar el primero.',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // Espacio para el botón +.
      itemCount: _gastos.length,
      itemBuilder: (context, i) => TarjetaGasto(
        gasto: _gastos[i],
        onTap: () => _abrirDetalle(_gastos[i]),
      ),
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
          Expanded(child: _construirLista()),
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
