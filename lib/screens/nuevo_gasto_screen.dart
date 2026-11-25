import 'package:material_ui/material_ui.dart';

import '../models/gasto.dart';
import '../services/api_tasas.dart';
import '../utils/constantes.dart';
import '../utils/formato.dart';

/// Pantalla 2: formulario con validación para registrar un gasto.
/// Si la moneda no es COP, consulta la tasa del día en la API.
/// Al guardar, devuelve el gasto a Inicio con Navigator.pop.
class NuevoGastoScreen extends StatefulWidget {
  const NuevoGastoScreen({super.key});

  @override
  State<NuevoGastoScreen> createState() => _NuevoGastoScreenState();
}

class _NuevoGastoScreenState extends State<NuevoGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _api = ApiTasas.instancia;

  String _categoria = categorias.first;
  String _moneda = 'COP';

  /// Pesos por 1 unidad de [_moneda]. Es null mientras no se conoce.
  double? _tasa = 1;
  bool _cargandoTasa = false;
  String? _errorTasa;

  @override
  void initState() {
    super.initState();
    // Al escribir el monto se vuelve a dibujar el equivalente en pesos.
    _montoCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // Los controladores se liberan para no dejar memoria ocupada.
    _descripcionCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cambiarMoneda(String moneda) async {
    setState(() {
      _moneda = moneda;
      _errorTasa = null;
      _cargandoTasa = false;
      _tasa = moneda == 'COP' ? 1 : null;
    });
    if (moneda != 'COP') await _cargarTasa();
  }

  /// Consulta la tasa de la moneda elegida. Maneja los estados de carga,
  /// éxito y error.
  Future<void> _cargarTasa() async {
    final moneda = _moneda;
    setState(() {
      _cargandoTasa = true;
      _errorTasa = null;
    });

    try {
      final tasas = await _api.obtenerTasas();
      // Si el usuario cerró la pantalla o cambió de moneda mientras
      // esperaba, esta respuesta ya no sirve.
      if (!mounted || moneda != _moneda) return;
      setState(() {
        _tasa = tasas.pesosPor(moneda);
        _cargandoTasa = false;
      });
    } catch (e) {
      if (!mounted || moneda != _moneda) return;
      setState(() {
        _errorTasa = e is ErrorApi ? e.mensaje : 'No hay tasa para $moneda.';
        _cargandoTasa = false;
      });
    }
  }

  double? get _montoEscrito =>
      double.tryParse(_montoCtrl.text.trim().replaceAll(',', '.'));

  String? _validarDescripcion(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe en qué gastaste';
    if (texto.length > 40) return 'Máximo 40 caracteres';
    return null;
  }

  String? _validarMonto(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe el monto';
    // En pesos, "15.000" se leería como 15; por eso se piden solo dígitos.
    if (_moneda == 'COP' && (texto.contains('.') || texto.contains(','))) {
      return 'En pesos escribe sin puntos ni comas';
    }
    final numero = double.tryParse(texto.replaceAll(',', '.'));
    if (numero == null) return 'Escribe solo números';
    if (numero <= 0) return 'El monto debe ser mayor que 0';
    return null;
  }

  void _guardar() {
    // validate() ejecuta todos los validadores y muestra los errores.
    if (!_formKey.currentState!.validate()) return;

    final tasa = _tasa;
    if (tasa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Todavía no hay tasa para $_moneda. Espera o toca Reintentar.',
          ),
        ),
      );
      return;
    }

    final gasto = Gasto(
      descripcion: _descripcionCtrl.text.trim(),
      montoOriginal: _montoEscrito!,
      moneda: _moneda,
      tasa: tasa,
      categoria: _categoria,
      fecha: DateTime.now(),
    );
    Navigator.pop(context, gasto);
  }

  /// Muestra la tasa según el estado: cargando, error o éxito.
  Widget _vistaConversion() {
    if (_moneda == 'COP') return const SizedBox.shrink();

    if (_cargandoTasa) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Consultando la tasa del día...'),
          ],
        ),
      );
    }

    final colores = Theme.of(context).colorScheme;

    if (_errorTasa != null) {
      return Card(
        color: colores.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_errorTasa!),
              TextButton.icon(
                onPressed: _cargarTasa,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final tasa = _tasa!;
    final monto = _montoEscrito;
    return Card(
      color: colores.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tasa de hoy: 1 $_moneda = ${formatoPesos(tasa)}'),
            if (monto != null && monto > 0)
              Text(
                'Este gasto equivale a ${formatoPesos(monto * tasa)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enPesos = _moneda == 'COP';

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo gasto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descripcionCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Ej: almuerzo, pasaje, Spotify',
                  border: OutlineInputBorder(),
                ),
                validator: _validarDescripcion,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _moneda,
                decoration: const InputDecoration(
                  labelText: 'Moneda',
                  border: OutlineInputBorder(),
                ),
                items: monedas.entries
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.key,
                        child: Text('${m.key} - ${m.value}'),
                      ),
                    )
                    .toList(),
                onChanged: (valor) {
                  if (valor != null && valor != _moneda) _cambiarMoneda(valor);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monto en $_moneda',
                  helperText: enPesos
                      ? 'Sin puntos de miles. Ej: 15000'
                      : 'Usa punto o coma para los centavos. Ej: 5.99',
                  border: const OutlineInputBorder(),
                ),
                validator: _validarMonto,
              ),
              const SizedBox(height: 8),
              _vistaConversion(),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _categoria,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (valor) {
                  if (valor != null) setState(() => _categoria = valor);
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _cargandoTasa ? null : _guardar,
                icon: const Icon(Icons.save),
                label: const Text('Guardar gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
