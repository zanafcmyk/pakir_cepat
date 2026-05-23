import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:parkir_cepat/app.dart';

void main() {
  testWidgets('renders Parkir Cepat splash content', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ParkirCepatApp(),
      ),
    );

    expect(find.text('Parkir Cepat'), findsOneWidget);
    expect(find.textContaining('Smart parking'), findsOneWidget);
  });
}
