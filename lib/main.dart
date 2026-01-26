import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Importações dos nossos módulos
import 'core/constants.dart';
import 'logic/game_engine.dart';
import 'widgets/game_screen.dart';
import 'core/sound_manager.dart';
import 'widgets/control_pad.dart';
import 'core/storage_manager.dart';

void main() {
  runApp(const SpaceConsoleApp());
}

class SpaceConsoleApp extends StatelessWidget {
  const SpaceConsoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NaveBoy',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final GameEngine _engine = GameEngine(); // Instância da lógica
  final SoundManager _soundManager = SoundManager();
  final StorageManager _storageManager = StorageManager();
  Timer? _gameLoopTimer;
  bool _gameStarted = false;
  bool _gameOver = false;
  bool _isPaused = false;

  int _debugTapCount = 0;

  @override
  void initState() {
    super.initState();
    _soundManager.init(); // Inicializa o som
    _loadHighScore();
    // --- CONEXÃO: LIGA OS FIOS ENTRE ENGINE E SOM ---
    // Quando a engine disser "Tiro", o SoundManager toca o tiro.
    _engine.onShootEvent = _soundManager.playShoot;
    _engine.onExplosionEvent = _soundManager.playExplosion;
  }

  void _loadHighScore() async {
    int savedScore = await _storageManager.loadHighScore();
    setState(() {
      _engine.highScore = savedScore;
    });
  }

  void _startGame() {
    if (_gameStarted && !_gameOver) return; // Jogo já rodando

    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _engine.reset();
    });

    _gameLoopTimer?.cancel();
    _gameLoopTimer = Timer.periodic(const Duration(milliseconds: 1000 ~/ GameConfig.fps), (timer) {
      if (!_isPaused) {
        setState(() {
          // Pede para a Engine calcular o próximo frame
          bool collision = _engine.update();
          if (collision) {
            _gameOver = true;
            _gameLoopTimer?.cancel();
          }
        });
      }
    });
  }

  void _togglePause() {
    if (_gameStarted && !_gameOver) {
      setState(() {
        _isPaused = !_isPaused;
      });
    }
  }

  @override
  void dispose() {
    _gameLoopTimer?.cancel();
    _soundManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.body,
      body: Column(
        children: [
          // Tela LCD
          Expanded(
            flex: 2,
            child: GameScreenLCD(
              engine: _engine, 
              gameStarted: _gameStarted, 
              gameOver: _gameOver,
              isPaused: _isPaused,
            ),
          ),
          
          // Logo
          GestureDetector(
            onTap: () {
              _debugTapCount++;
              if (_debugTapCount >= 3) {
                setState(() {
                  _engine.toggleDebugMode(); // Ativa/Desativa as hitboxes
                  debugPrint("Debug Mode: ${_engine.showHitboxes}");
                  _debugTapCount = 0; // Reseta o contador
                });
              }
            },
            child: const Text("SpaceBoy", 
              style: TextStyle(
                color: Color(0xFF303080), 
                fontWeight: FontWeight.bold, 
                fontStyle: FontStyle.italic,
                fontSize: 24
              )
            ),
          ),

          // Controles
          Expanded(
            flex: 1,
            child: ControlPad(
              onStart: _startGame,
              onPause: _togglePause,
              onJet: (active) => _engine.activateJet(active),
              onFire: () {
                if (_gameStarted && !_gameOver) _engine.fire();
              },
            ),
          ),
        ],
      ),
    );
  }
}