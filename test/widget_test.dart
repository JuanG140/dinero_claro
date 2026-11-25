import 'package:flutter_test/flutter_test.dart';

import 'package:dinero_claro/main.dart';

void main() {
  testWidgets('Inicio muestra el título y el total del mes', (tester) async {
    await tester.pumpWidget(const DineroClaroApp());

    expect(find.text('DineroClaro'), findsOneWidget);
    expect(find.text('Gastado este mes'), findsOneWidget);
  });
}
