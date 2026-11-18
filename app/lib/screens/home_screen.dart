import 'package:flutter/material.dart';

import '../core/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NowBank')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available balance', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('R\$ 4,312.78',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('My account', style: TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Statement'),
            onTap: () => Navigator.pushNamed(context, Routes.statement),
          ),
          ListTile(
            leading: const Icon(Icons.local_offer_outlined),
            title: const Text('Offer: no-annual-fee card'),
            onTap: () => Navigator.pushNamed(context, '${Routes.offer}/42'),
          ),
        ],
      ),
    );
  }
}
