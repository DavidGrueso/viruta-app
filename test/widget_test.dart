import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('renderiza la pantalla de autenticacion', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const VirutaApp());
    await tester.pumpAndSettle();

    expect(find.text('VIRUTA'), findsOneWidget);
    expect(find.text('Iniciar sesion'), findsOneWidget);
  });
}
