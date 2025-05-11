import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TimerDisplay extends StatelessWidget {
  final int secondsRemaining;

  const TimerDisplay({super.key, required this.secondsRemaining});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer, color: Colors.red.shade700, size: 28),
        const SizedBox(width: 8),
        Text(
          '$secondsRemaining segundos',
          style: TextStyle(
            fontSize: 20,
            color: Colors.red.shade700,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}