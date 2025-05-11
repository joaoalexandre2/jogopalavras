import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RoundInfo extends StatelessWidget {
  final int currentRound;
  final int maxRounds;

  const RoundInfo({super.key, required this.currentRound, required this.maxRounds});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade300.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        'Rodada: $currentRound/$maxRounds',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'Roboto',
        ),
        textAlign: TextAlign.center,
      ),
    ).animate().slideY(duration: 400.ms);
  }
}