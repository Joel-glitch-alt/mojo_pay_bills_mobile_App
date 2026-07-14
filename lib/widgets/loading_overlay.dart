import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final double progress;

  const LoadingOverlay({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: progress,
              color: const Color.fromARGB(255, 43, 18, 234),
            ),
            const SizedBox(height: 10),
            Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
