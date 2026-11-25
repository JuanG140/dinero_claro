import 'package:material_ui/material_ui.dart';

import '../models/gasto.dart';
import '../utils/constantes.dart';

/// Pantalla 2: formulario con validación para registrar un gasto.
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
  String _categoria = categorias.first;

  @override
  void dispose() {
    // Los controladores se liberan para no dejar memoria ocupada.
    _descripcionCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  String? _validarDescripcion(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe en qué gastaste';
    if (texto.length > 40) return 'Máximo 40 caracteres';
    return null;
  }

  String? _validarMonto(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return 'Escribe el monto';
    final numero = double.tryParse(texto.replaceAll(',', '.'));
    if (numero == null) return 'Escribe solo números';
    if (numero <= 0) return 'El monto debe ser mayor que 0';
    return null;
  }

  void _guardar() {
    // validate() ejecuta todos los validadores y muestra los errores.
    if (!_formKey.currentState!.validate()) return;

    final gasto = Gasto(
      descripcion: _descripcionCtrl.text.trim(),
      montoOriginal: double.parse(_montoCtrl.text.trim().replaceAll(',', '.')),
      moneda: 'COP', // En la etapa 4 se podrá elegir USD o EUR.
      tasa: 1,
      categoria: _categoria,
      fecha: DateTime.now(),
    );
    Navigator.pop(context, gasto);
  }

  @override
  Widget build(BuildContext context) {
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
              TextFormField(
                controller: _montoCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto en pesos',
                  helperText: 'Sin puntos de miles. Ej: 15000',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: _validarMonto,
              ),
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
                onPressed: _guardar,
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
