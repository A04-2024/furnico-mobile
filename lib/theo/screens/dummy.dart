import 'package:flutter/material.dart';

class DummyPage extends StatelessWidget {
  const DummyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dummy Page'),
      ),
      body: const Center(
        child: Text(
          'Ini adalah halaman dummy',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class AnotherDummyPage extends StatelessWidget {
  const AnotherDummyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Another Dummy Page'),
      ),
      body: const Center(
        child: Text(
          'Halaman Dummy lainnya!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
