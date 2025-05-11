import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WordList extends StatelessWidget {
  final List<String> words;

  const WordList({super.key, required this.words});

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, size: 40, color: Colors.blueGrey.shade300),
              const SizedBox(height: 8),
              Text(
                'Nenhuma palavra encontrada ainda.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey.shade600,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: words.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green.shade600),
            title: Text(
              words[index],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
            trailing: Text(
              '+${words[index].length}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ).animate().slideX(duration: 400.ms, delay: (index * 100).ms);
      },
    );
  }
}