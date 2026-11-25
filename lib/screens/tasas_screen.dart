import 'package:material_ui/material_ui.dart';

import '../models/tasas_cambio.dart';
import '../services/api_tasas.dart';
import '../utils/constantes.dart';
import '../utils/formato.dart';

/// Pantalla 4: cuántos pesos valen hoy 1 dólar y 1 euro, según la API.
/// Maneja los estados de carga, éxito y error, con botón para reintentar.
class TasasScreen extends StatefulWidget {
  const TasasScreen({super.key});

  @override
  State<TasasScreen> createState() => _TasasScreenState();
}

class _TasasScreenState extends State<TasasScreen> {
  final _api = ApiTasas.instancia;

  TasasCambio? _tasas;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar({bool forzar = false}) async {
    try {
      final tasas = await _api.obtenerTasas(forzar: forzar);
      if (!mounted) return;
      setState(() {
        _tasas = tasas;
        _cargando = false;
        _error = null;
      });
    } on ErrorApi catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = e.mensaje;
      });
    }
  }

  /// Vuelve a consultar la API sin usar la caché.
  void _actualizar() {
    setState(() {
      _cargando = true;
      _error = null;
    });
    _cargar(forzar: true);
  }

  Widget _construirCuerpo() {
    if (_cargando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Consultando las tasas del día...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _actualizar,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final tasas = _tasas!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final codigo in ['USD', 'EUR'])
          _TarjetaTasa(
            codigo: codigo,
            nombre: monedas[codigo]!,
            pesos: tasas.pesosPor(codigo),
          ),
        const SizedBox(height: 16),
        Text('Actualizado por la fuente el ${formatoFecha(tasas.actualizacion)}'),
        const SizedBox(height: 4),
        Text(
          'Tasas por ExchangeRate-API (exchangerate-api.com)',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasas del día'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _cargando ? null : _actualizar,
          ),
        ],
      ),
      body: _construirCuerpo(),
    );
  }
}

/// Tarjeta con el valor en pesos de una moneda.
class _TarjetaTasa extends StatelessWidget {
  final String codigo;
  final String nombre;
  final double pesos;

  const _TarjetaTasa({
    required this.codigo,
    required this.nombre,
    required this.pesos,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(codigo == 'USD' ? 'US\$' : '€')),
        title: Text(nombre),
        subtitle: Text('1 $codigo'),
        trailing: Text(
          formatoPesos(pesos),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
