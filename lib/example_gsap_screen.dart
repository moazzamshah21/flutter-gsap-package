import 'package:flutter/material.dart';
import 'package:flutter_gsap/flutter_gsap.dart';

/// Example screen showing flutter_gsap: scroll animate, stagger, parallax, scrub.
class ExampleGsapScreen extends StatelessWidget {
  const ExampleGsapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_gsap')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 24),
          GScrollAnimate(
            offset: const Offset(0, 60),
            duration: const Duration(milliseconds: 700),
            curve: GEase.backOut,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'GScrollAnimate — animates once when visible',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          GScrollAnimate(
            scrub: true,
            offset: const Offset(80, 0),
            duration: const Duration(milliseconds: 500),
            child: Card(
              color: Colors.blue.shade100,
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Scrub: progress tied to scroll (scroll up/down)',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          GStagger(
            staggerDelay: const Duration(milliseconds: 120),
            children: [
              _tile('Stagger 1', Colors.green),
              _tile('Stagger 2', Colors.teal),
              _tile('Stagger 3', Colors.cyan),
            ],
          ),
          const SizedBox(height: 24),
          GParallax(
            factor: 0.2,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text('GParallax — moves slower than scroll'),
            ),
          ),
          const SizedBox(height: 24),
          GScrollProgress(
            builder: (context, progress) {
              return Opacity(
                opacity: 0.5 + 0.5 * progress,
                child: Card(
                  color: Colors.purple.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'GScrollProgress: ${(progress * 100).round()}%',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _tile(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
