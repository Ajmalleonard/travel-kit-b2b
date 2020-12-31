import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:twendezanzibar_b2b/main.dart';

void main() {
  testWidgets('App renders without throwing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TwendePartnersApp()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
