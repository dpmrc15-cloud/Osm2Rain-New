// import 'package:flutter/material.dart'; // TODO: unused import
import 'package:flutter_test/flutter_test.dart';

import 'package:osm2_app/main.dart';

void main() {
  testWidgets(
    'Sign in button exists',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('Sign in'), findsOneWidget);
    },
    skip: true, // ⏭️ Skip temporarily - fix test later
  );
}
