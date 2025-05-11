import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WordInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onVerify;
  final String prefix;

  const WordInput({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onVerify,
    required this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Complete a palavra',
            prefix: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                prefix,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.blueGrey.shade400),
              onPressed: () => controller.clear(),
            ),
          ),
          onSubmitted: (_) => onVerify(),
          enabled: !isLoading,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: isLoading ? null : onVerify,
          icon: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.check, size: 24),
          label: const Text('Verificar Palavra'),
        ).animate().fadeIn(duration: 400.ms),
      ],
    );
  }
}
