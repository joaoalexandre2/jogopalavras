import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PrefixDisplay extends StatelessWidget {
  final String prefix;

  const PrefixDisplay({super.key, required this.prefix});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade400.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'Prefixo: $prefix',
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Roboto',
        ),
        textAlign: TextAlign.center,
      ),
    ).animate().scale(duration: 400.ms);
  }
}