import 'package:material_ui/material_ui.dart';

import 'screens/inicio_screen.dart';

void main() {
  runApp(const DineroClaroApp());
}

/// Widget raíz de la aplicación: define el tema y la pantalla inicial.
class DineroClaroApp extends StatelessWidget {
  const DineroClaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DineroClaro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const InicioScreen(),
    );
  }
}
