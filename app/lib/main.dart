import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'core/routes.dart';
import 'screens/support_tool_app.dart';

void main() => runApp(const NowBankApp());

@pragma('vm:entry-point')
void supportMain() => runApp(const SupportToolApp());

class NowBankApp extends StatelessWidget {
  const NowBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NowBank',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      initialRoute: ui.PlatformDispatcher.instance.defaultRouteName,
      onGenerateRoute: Routes.onGenerateRoute,
    );
  }
}
