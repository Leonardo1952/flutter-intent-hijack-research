import 'package:flutter/material.dart';

import '../screens/diagnostics_screen.dart';
import '../screens/home_screen.dart';
import '../screens/offer_screen.dart';
import '../screens/session_screen.dart';
import '../screens/statement_screen.dart';
import '../screens/support_panel_screen.dart';
import '../screens/transfer_screen.dart';

abstract final class Routes {
  static const home = '/';
  static const statement = '/statement';
  static const offer = '/offers';
  static const diagnostics = '/diagnostics';

  static const transfer = '/transfer';
  static const support = '/support';

  static const session = '/session';

  static const sensitive = {transfer, support, session};

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? home);
    final builder = switch (uri.pathSegments) {
      [] => (_) => const HomeScreen(),
      ['statement'] => (_) => const StatementScreen(),
      ['diagnostics'] => (_) => const DiagnosticsScreen(),
      ['transfer'] => (_) => const TransferScreen(),
      ['support'] => (_) => const SupportPanelScreen(),
      ['session'] => (_) => const SessionScreen(),
      ['offers', final id] => (_) => OfferScreen(id: id),
      _ => (_) => const HomeScreen(),
    };
    return MaterialPageRoute(builder: builder, settings: settings);
  }
}
