import 'package:flutter/material.dart';

class StatementScreen extends StatelessWidget {
  const StatementScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Statement')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ListTile(title: Text('Downtown Supermarket'), trailing: Text('-R\$ 87.40')),
            ListTile(title: Text('Transfer received'), trailing: Text('+R\$ 500.00')),
            ListTile(title: Text('Streaming subscription'), trailing: Text('-R\$ 29.90')),
          ],
        ),
      );
}
