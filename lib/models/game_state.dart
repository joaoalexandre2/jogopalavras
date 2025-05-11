import 'package:flutter/material.dart';

enum GamePhase {
  iniciante(0, 'Iniciante', Colors.blue),
  aprendiz(80, 'Aprendiz', Colors.green),
  intermediario(200, 'Intermediário', Colors.amber),
  avancado(300, 'Avançado', Colors.orange),
  expert(450, 'Expert', Colors.red),
  mestre(600, 'Mestre', Colors.purple),
  lenda(800, 'Lenda das Palavras', Colors.deepPurple);

  final int requiredScore;
  final String title;
  final Color color;

  const GamePhase(this.requiredScore, this.title, this.color);
}

class GameState {
  List<String> foundWords = [];
  int score = 0;
  String feedbackMessage = '';
  bool isLoading = false;
  String currentPrefix = '';
  int secondsRemaining = 60;
  bool gameOver = false;
  int currentRound = 1;
  final int maxRounds = 3;
  List<String> prefixes = [];
  GamePhase _currentPhase = GamePhase.iniciante;
  bool _canLevelUp = false;

  GamePhase get currentPhase => _currentPhase;
  bool get canLevelUp => _canLevelUp;

  void checkPhaseUpdate(bool roundCompleted) {
    if (roundCompleted) {
      _canLevelUp = true;
    }
    
    if (_canLevelUp) {
      final nextPhaseIndex = GamePhase.values.indexOf(_currentPhase) + 1;
      if (nextPhaseIndex < GamePhase.values.length && 
          score >= GamePhase.values[nextPhaseIndex].requiredScore) {
        _currentPhase = GamePhase.values[nextPhaseIndex];
        _canLevelUp = false;
        feedbackMessage = 'Parabéns! Você alcançou a fase ${_currentPhase.title}!';
      }
    }
  }

  void reset() {
    foundWords.clear();
    score = 0;
    feedbackMessage = '';
    isLoading = false;
    secondsRemaining = 60;
    gameOver = false;
    currentRound = 1;
    _currentPhase = GamePhase.iniciante;
    _canLevelUp = false;
  }
}