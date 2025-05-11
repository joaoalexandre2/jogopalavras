import 'package:flutter/material.dart';

class FeedbackMessage extends StatelessWidget {
  final String message;
  final Animation<double> animation;

  const FeedbackMessage({super.key, required this.message, required this.animation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        padding: message.isNotEmpty ? const EdgeInsets.all(12) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: message.contains('válida') || message.contains('Parabéns')
              ? Colors.green.shade100
              : message.contains('Erro') || message.contains('inválida') || message.contains('já encontrada')
                  ? Colors.red.shade100
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: message.contains('válida') || message.contains('Parabéns') 
                ? Colors.green.shade800 
                : Colors.red.shade800,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}