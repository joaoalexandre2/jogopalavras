import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jogopalavras/models/game_state.dart';
import 'package:jogopalavras/widgets/round_info.dart';
import 'package:jogopalavras/widgets/prefix_display.dart';
import 'package:jogopalavras/widgets/timer_display.dart';
import 'package:jogopalavras/widgets/score_display.dart';
import 'package:jogopalavras/widgets/phase_display.dart';
import 'package:jogopalavras/widgets/word_input.dart';
import 'package:jogopalavras/widgets/feedback_message.dart';
import 'package:jogopalavras/widgets/word_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _wordController = TextEditingController();
  final GameState _gameState = GameState();
  Timer? _timer;
  bool _isLoadingPrefixes = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showTutorial = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadPrefixes().then((_) {
      setState(() {
        _isLoadingPrefixes = false;
      });
      if (_gameState.prefixes.isNotEmpty) {
        _startNewRound();
      }
    });
  }

  Future<void> _loadPrefixes() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedPrefixes = prefs.getStringList('prefixes');

    if (cachedPrefixes != null && cachedPrefixes.isNotEmpty) {
      setState(() {
        _gameState.prefixes = cachedPrefixes;
      });
    } else {
      await _loadDynamicPrefixes();
      await prefs.setStringList('prefixes', _gameState.prefixes);
    }
  }

  Future<void> _loadDynamicPrefixes() async {
    const initialPrefixes = [
      'pre', 'com', 'ver', 'mar', 'luz', 'por', 'des', 'bro', 'sol', 'cas',
      'sub', 'pro', 'con', 'dis', 'mis', 'tri', 'uni', 'bio', 'geo', 'hid',
      'arte', 'tech', 'sust', 'ambi', 'cult'
    ];
    Set<String> dynamicPrefixes = {};

    final futures = initialPrefixes.map((prefix) async {
      try {
        final response = await http
            .get(Uri.parse('https://api.dicionario-aberto.net/prefix/$prefix'))
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
          List<dynamic> data = decodedData is List ? decodedData : decodedData['results'] ?? [];

          for (var entry in data) {
            if (entry['word'] != null) {
              String word = entry['word'].toString().toLowerCase();
              if (word.length >= 3) {
                String newPrefix = word.substring(0, 3);
                dynamicPrefixes.add(newPrefix);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error loading prefix $prefix: $e');
      }
    }).toList();

    await Future.wait(futures);

    if (dynamicPrefixes.length < 50) {
      dynamicPrefixes.addAll(initialPrefixes);
    }

    setState(() {
      _gameState.prefixes = dynamicPrefixes.toList();
      if (_gameState.prefixes.isEmpty) {
        _gameState.feedbackMessage = 'Erro ao carregar prefixos. Verifique sua conexão.';
        _gameState.gameOver = true;
      }
    });
  }

  void _startNewRound() {
    setState(() {
      _gameState.foundWords.clear();
      _gameState.feedbackMessage = '';
      _gameState.secondsRemaining = 60;
      _gameState.currentPrefix = _gameState.prefixes[Random().nextInt(_gameState.prefixes.length)];
      _wordController.clear();
    });
    _startTimer();
  }

  void _startNewGame() {
    setState(() {
      _gameState.reset();
      _gameState.currentPrefix = _gameState.prefixes[Random().nextInt(_gameState.prefixes.length)];
      _wordController.clear();
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_gameState.secondsRemaining > 0) {
          _gameState.secondsRemaining--;
        } else {
          timer.cancel();
          if (_gameState.currentRound < _gameState.maxRounds) {
            _gameState.currentRound++;
            _gameState.feedbackMessage = 'Rodada ${_gameState.currentRound}/${_gameState.maxRounds} começando!';
            _animationController.forward(from: 0);
            _startNewRound();
          } else {
            _gameState.checkPhaseUpdate(true);
            _gameState.gameOver = true;
            
            String phaseMessage = '';
            final nextPhaseIndex = GamePhase.values.indexOf(_gameState.currentPhase) + 1;
            if (_gameState.canLevelUp && 
                nextPhaseIndex < GamePhase.values.length &&
                _gameState.score < GamePhase.values[nextPhaseIndex].requiredScore) {
              phaseMessage = ' Complete ${GamePhase.values[nextPhaseIndex].requiredScore - _gameState.score} pontos para próxima fase!';
            }
            
            _gameState.feedbackMessage = 'Fim do jogo! Placar final: ${_gameState.score}.$phaseMessage';
            _animationController.forward(from: 0);
          }
        }
      });
    });
  }

  Future<bool> _checkWord(String prefix, String word) async {
    try {
      final response = await http
          .get(Uri.parse('https://api.dicionario-aberto.net/prefix/$prefix'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> data = decodedData is List ? decodedData : decodedData['results'] ?? [];

        return data.any((entry) =>
            entry['word']?.toString().toLowerCase() == word.toLowerCase());
      }
    } catch (e) {
      debugPrint('Error checking word: $e');
    }
    return false;
  }

  void _verifyWord() async {
    if (_gameState.gameOver) return;

    final input = _wordController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _gameState.feedbackMessage = 'Por favor, complete a palavra.';
        _animationController.forward(from: 0);
      });
      return;
    }

    final word = _gameState.currentPrefix + input;
    final previousPhase = _gameState.currentPhase;

    setState(() {
      _gameState.isLoading = true;
      _gameState.feedbackMessage = '';
    });

    final isValid = await _checkWord(_gameState.currentPrefix, word);

    setState(() {
      _gameState.isLoading = false;
      if (isValid && !_gameState.foundWords.contains(word.toLowerCase())) {
        _gameState.foundWords.add(word.toLowerCase());
        _gameState.score += word.length;
        
        _gameState.feedbackMessage = 'Palavra válida! 🎉 +${word.length} pontos';
      } else if (_gameState.foundWords.contains(word.toLowerCase())) {
        _gameState.feedbackMessage = 'Palavra já encontrada!';
      } else {
        _gameState.feedbackMessage = 'Palavra inválida ou não encontrada.';
      }
      _wordController.clear();
      _animationController.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPrefixes) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.blue.shade700),
              const SizedBox(height: 16),
              Text(
                'Carregando prefixos...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey.shade600,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_gameState.prefixes.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Jogo de Palavras'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade600),
              const SizedBox(height: 16),
              Text(
                _gameState.feedbackMessage,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoadingPrefixes = true;
                    _gameState.feedbackMessage = '';
                    _gameState.gameOver = false;
                  });
                  _loadPrefixes().then((_) {
                    setState(() {
                      _isLoadingPrefixes = false;
                      if (_gameState.prefixes.isNotEmpty) {
                        _startNewRound();
                      }
                    });
                  });
                },
                icon: const Icon(Icons.refresh, size: 24),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_showTutorial) {
      return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Bem-vindo ao Jogo de Palavras!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      fontFamily: 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Complete palavras começando com o prefixo mostrado.\n'
                    'Cada palavra válida adiciona pontos com base em seu tamanho.\n'
                    'Você tem 60 segundos por rodada, com 3 rodadas no total!\n\n'
                    'Fases do jogo (avança após completar 3 rodadas):\n'
                    '- Iniciante: 0 pts\n'
                    '- Aprendiz: 80 pts\n'
                    '- Intermediário: 200 pts\n'
                    '- Avançado: 300 pts\n'
                    '- Expert: 450 pts\n'
                    '- Mestre: 600 pts\n'
                    '- Lenda: 800 pts',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                      fontFamily: 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showTutorial = false;
                      });
                    },
                    child: const Text('Começar o Jogo'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogo de Palavras'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              setState(() {
                _showTutorial = true;
              });
            },
            tooltip: 'Como Jogar',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RoundInfo(
                        currentRound: _gameState.currentRound,
                        maxRounds: _gameState.maxRounds,
                      ),
                      const SizedBox(height: 16),
                      PrefixDisplay(prefix: _gameState.currentPrefix),
                      const SizedBox(height: 12),
                      TimerDisplay(secondsRemaining: _gameState.secondsRemaining),
                      const SizedBox(height: 12),
                      ScoreDisplay(score: _gameState.score),
                      const SizedBox(height: 8),
                      PhaseDisplay(
                        phase: _gameState.currentPhase,
                        score: _gameState.score,
                        canLevelUp: _gameState.canLevelUp,
                        roundsCompleted: _gameState.currentRound - 1,
                      ),
                      const SizedBox(height: 12),
                      if (!_gameState.gameOver)
                        WordInput(
                          controller: _wordController,
                          isLoading: _gameState.isLoading,
                          onVerify: _verifyWord,
                          prefix: _gameState.currentPrefix,
                        ),
                      if (_gameState.gameOver)
                        ElevatedButton.icon(
                          onPressed: _startNewGame,
                          icon: const Icon(Icons.play_arrow, size: 24),
                          label: const Text('Jogar Novamente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                          ),
                        ).animate().fadeIn(duration: 600.ms),
                      const SizedBox(height: 20),
                      FeedbackMessage(
                        message: _gameState.feedbackMessage,
                        animation: _fadeAnimation,
                      ),
                      const SizedBox(height: 20),
                      WordList(words: _gameState.foundWords),
                      const SizedBox(height: 8),
                      Text(
                        'Prefixos disponíveis: ${_gameState.prefixes.length}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey.shade500,
                          fontFamily: 'Roboto',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}