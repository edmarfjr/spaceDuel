import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart'; 

// Importações dos seus módulos
import 'core/constants.dart';
import 'logic/game_engine.dart';
import 'widgets/game_screen.dart';
import 'core/sound_manager.dart';
import 'widgets/control_pad.dart';
import 'core/storage_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const SpaceConsoleApp());
}

class SpaceConsoleApp extends StatelessWidget {
  const SpaceConsoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NaveBoy',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF202020),
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  final GameEngine _engine = GameEngine();
  final SoundManager _soundManager = SoundManager();
  final StorageManager _storageManager = StorageManager();
  
  late Ticker _ticker; 

  bool _gameStarted = false;
  bool _gameOver = false;
  bool _isPaused = false;

  int _debugTapCount = 0;

  // --- VARIÁVEIS PARA O GAME LOOP ESTÁVEL ---
  Duration _lastElapsed = Duration.zero;
  double _timeAccumulator = 0.0;
  // Define que a física deve rodar a 60 FPS (aprox 0.0166s por frame)
  final double _stepTime = 1.0 / GameConfig.fps; 

  @override
  void initState() {
    super.initState();
    _soundManager.init();
    _loadHighScore();

    _engine.onShootEvent = _soundManager.playShoot;
    _engine.onExplosionEvent = _soundManager.playExplosion;
    _engine.onNewHighScoreEvent = (int newRecord) {
      _storageManager.saveHighScore(newRecord);
    };

    // --- GAME LOOP COM FIXED TIMESTEP ---
    // Isso garante a mesma velocidade em telas de 60hz, 90hz ou 120hz
    _ticker = createTicker((elapsed) {
      if (!_gameStarted || _gameOver || _isPaused) {
        // Se pausado, apenas atualizamos o lastElapsed para não acumular tempo gigante
        _lastElapsed = elapsed;
        return;
      }

      // 1. Calcula quanto tempo passou desde o último frame (em segundos)
      double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
      _lastElapsed = elapsed;

      // Proteção contra "Espiral da Morte" (se o app travar muito, limita o dt)
      if (dt > 0.1) dt = 0.1;

      // 2. Acumula o tempo
      _timeAccumulator += dt;

      // 3. Roda a física quantas vezes forem necessárias para "alcançar" o tempo real
      // Ex: Se passou 0.033s (30fps), rodamos o update 2 vezes (2 * 0.016s)
      bool playerDied = false;
      while (_timeAccumulator >= _stepTime) {
        playerDied = _engine.update(); // <--- AQUI A MÁGICA
        _timeAccumulator -= _stepTime;
        
        if (playerDied) break;
      }

      if (playerDied) {
        setState(() {
          _gameOver = true;
          _gameStarted = false;
        });
      } else {
        // 4. Renderiza a tela (uma vez por frame visual)
        setState(() {}); 
      }
    });
    
    _ticker.start();
  }

  void _loadHighScore() async {
    int savedScore = await _storageManager.loadHighScore();
    setState(() {
      _engine.highScore = savedScore;
    });
  }

  void _startGame() {
    if (_gameStarted && !_gameOver) return;

    setState(() {
      _gameStarted = true;
      _gameOver = false;
      _engine.reset();
      _isPaused = false;
      
      // Reseta os contadores de tempo para não dar um pulo inicial
      _timeAccumulator = 0.0;
      _lastElapsed = Duration.zero; 
      // Se o ticker já estiver rodando, precisamos sincronizar o _lastElapsed
      // mas como usamos elapsed do callback, ele se ajusta no próximo frame.
    });
  }

  void _togglePause() {
    if (_gameStarted && !_gameOver) {
      setState(() {
        _isPaused = !_isPaused;
        // Ao despausar, reseta o acumulador para evitar que o jogo tente "compensar" o tempo parado
        _timeAccumulator = 0.0;
      });
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _soundManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.body,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 7,
              child: GameScreenLCD(
                engine: _engine, 
                gameStarted: _gameStarted, 
                gameOver: _gameOver,
                isPaused: _isPaused,
                onToggleSound: () {
                  setState(() {
                    _engine.toggleSound();
                  });
                },
              ),
            ),
            
            GestureDetector(
              onTap: () {
                _debugTapCount++;
                if (_debugTapCount >= 3) {
                  setState(() {
                    _engine.toggleDebugMode();
                    _debugTapCount = 0;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Debug Mode: ${_engine.showHitboxes}"), duration: const Duration(seconds: 1)),
                  );
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text("SpaceBoy", 
                  style: TextStyle(
                    color: Color(0xFF303080), 
                    fontWeight: FontWeight.bold, 
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Courier',
                    fontSize: 28
                  )
                ),
              ),
            ),

            // Controles (Mantidos conforme sua versão)
            Expanded(
              flex: 3,
              child: ControlPad(
                onStart: _startGame,
                onPause: _togglePause,
                // Mantendo sua lógica original de movimento
                onToggleDir: () => _engine.toggleDir(), 
                onFire: () {
                  if (!_isPaused) {
                    if (!_gameStarted && !_gameOver) {
                       _startGame();
                    } else {
                       _engine.fire();
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}