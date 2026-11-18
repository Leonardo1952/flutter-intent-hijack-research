import 'package:flutter/material.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Transfer')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('To', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(Icons.account_circle_outlined),
                title: Text('Maria Fernandes'),
                subtitle: Text('Bank 341 · Branch 0012 · Account 55.812-3'),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Amount', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('R\$ 500.00', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 24),
            const Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Today'),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Confirm transfer'),
              ),
            ),
          ],
        ),
      );
}
