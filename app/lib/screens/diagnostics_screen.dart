import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/intent_info.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Integration diagnostics')),
      body: FutureBuilder<IntentInfo>(
        future: IntentInfo.load(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final i = snap.data!;
          final rows = <(String, String)>[
            ('Activity', i.activity),
            ('Action', '${i.action}'),
            ('Data (deep link)', '${i.data}'),
            ('Extras', i.extras.isEmpty ? '(none)' : i.extras.entries.map((e) => '${e.key} = ${e.value}').join('\n')),
            ('callingPackage', '${i.callingPackage}'),
            ('ownPackage', '${i.ownPackage}'),
            ('defaultRouteName (Dart)', ui.PlatformDispatcher.instance.defaultRouteName),
          ];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final (k, v) in rows)
                ListTile(dense: true, title: Text(k), subtitle: SelectableText(v)),
            ],
          );
        },
      ),
    );
  }
}
