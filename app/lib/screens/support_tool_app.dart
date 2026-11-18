import 'package:flutter/material.dart';

class SupportToolApp extends StatelessWidget {
  const SupportToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NowBank Support',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Support console')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search customer (CPF or account)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: Icon(Icons.account_circle_outlined),
                title: Text('Maria Fernandes'),
                subtitle: Text('CPF 123.456.789-00 · Account 00123-4'),
                trailing: Icon(Icons.chevron_right),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
