import 'package:flutter/material.dart';

import '../../../core/widgets/overlay_shimmer.dart';

class InteractiveScreen extends StatefulWidget {
  const InteractiveScreen({super.key});

  @override
  State<InteractiveScreen> createState() => _InteractiveScreenState();
}

class _InteractiveScreenState extends State<InteractiveScreen> {
  int counter = 0;

  void increase() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Interactive Screen")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Count: $counter"),
            OverlayShimmer(
              borderRadius: BorderRadius.circular(12),
              child: ElevatedButton(
                onPressed: increase,
                child: const Text("Tap Me"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
