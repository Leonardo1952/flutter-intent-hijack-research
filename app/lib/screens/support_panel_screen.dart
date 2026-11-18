import 'package:flutter/material.dart';

class SupportPanelScreen extends StatelessWidget {
  const SupportPanelScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Customer record')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ListTile(dense: true, title: Text('Name'), subtitle: Text('Maria Fernandes')),
            ListTile(dense: true, title: Text('CPF'), subtitle: Text('123.456.789-00')),
            ListTile(dense: true, title: Text('Account'), subtitle: Text('Branch 0012 · Account 00123-4')),
            ListTile(dense: true, title: Text('Phone'), subtitle: Text('(11) 98765-4321')),
            ListTile(dense: true, title: Text('E-mail'), subtitle: Text('maria.fernandes@example.com')),
            ListTile(dense: true, title: Text('Account status'), subtitle: Text('Active')),
          ],
        ),
      );
}
