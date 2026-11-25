import 'package:material_ui/material_ui.dart';

/// Pantalla 4: tasas de cambio del día.
/// Por ahora es un marcador; en la etapa 4 se conecta a la API.
class TasasScreen extends StatelessWidget {
  const TasasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasas del día')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_download_outlined, size: 64),
              SizedBox(height: 16),
              Text(
                'Aquí se mostrarán cuántos pesos vale hoy\n1 dólar y 1 euro.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
