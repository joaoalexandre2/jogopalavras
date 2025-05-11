import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jogopalavras/models/game_state.dart';

class PhaseDisplay extends StatelessWidget {
  final GamePhase phase;
  final int score;
  final bool canLevelUp;
  final int roundsCompleted;

  const PhaseDisplay({
    super.key,
    required this.phase,
    required this.score,
    required this.canLevelUp,
    required this.roundsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final nextPhaseIndex = GamePhase.values.indexOf(phase) + 1;
    final hasNextPhase = nextPhaseIndex < GamePhase.values.length;
    final nextPhase = hasNextPhase ? GamePhase.values[nextPhaseIndex] : null;
    
    double progress = 0;
    String progressText = '';
    
    if (hasNextPhase) {
      if (canLevelUp) {
        progress = score / nextPhase!.requiredScore;
        progressText = 'Faltam ${nextPhase.requiredScore - score} pontos para ${nextPhase.title}';
      } else {
        progress = roundsCompleted / 3;
        progressText = '${3 - roundsCompleted} rodadas restantes para desbloquear progresso';
      }
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: phase.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: phase.color, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star, color: phase.color),
              const SizedBox(width: 8),
              Text(
                'Fase: ${phase.title}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: phase.color,
                  fontFamily: 'Roboto',
                ),
              ),
              if (phase != GamePhase.iniciante) ...[
                const SizedBox(width: 8),
                Text(
                  '(${phase.requiredScore}+ pts)',
                  style: TextStyle(
                    fontSize: 14,
                    color: phase.color.withOpacity(0.8),
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ],
          ),
        ),
        if (hasNextPhase) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.shade200,
            color: phase.color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 4),
          Text(
            progressText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blueGrey.shade600,
              fontFamily: 'Roboto',
            ),
            textAlign: TextAlign.center,
          ),
        ] else ...[
          const SizedBox(height: 4),
          Text(
            'Fase máxima alcançada!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}