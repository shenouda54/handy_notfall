import 'package:flutter/material.dart';

class RechnungVerkaufeScreen extends StatelessWidget {
  final String customerId;
  final int printId;

  const RechnungVerkaufeScreen({
    super.key,
    required this.customerId,
    required this.printId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rechnung verkaufe')),
      body: const Center(child: Text('Verkaufs PDF Page')),
    );
  }
}
