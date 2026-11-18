import 'package:flutter/material.dart';

class SessionScreen extends StatelessWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('My account')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hi, Maria', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('R\$ 4,312.78',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text('Statement'),
            ),
            const ListTile(
              leading: Icon(Icons.swap_horiz),
              title: Text('Transfers'),
            ),
          ],
        ),
      );
}
