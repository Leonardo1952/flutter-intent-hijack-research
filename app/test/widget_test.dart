import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:banco_now/core/routes.dart';
import 'package:banco_now/main.dart';

void main() {
  testWidgets('opens the home screen', (tester) async {
    await tester.pumpWidget(const NowBankApp());
    expect(find.text('NowBank'), findsWidgets);
  });

  test('dynamic and sensitive routes', () {
    expect(Routes.onGenerateRoute(const RouteSettings(name: '/offers/7')).settings.name, '/offers/7');
    expect(Routes.sensitive, containsAll(['/transfer', '/support', '/session']));
  });
}
