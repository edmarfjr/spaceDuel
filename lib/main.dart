import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart'; // <--- IMPORTANTE: Necessário para o Ticker

// Importações dos seus módulos
import 'core/constants.dart';
import 'logic/game_engine.dart';
import 'widgets/game_screen.dart';
import 'core/sound_manager.dart';
import 'widgets/control_pad.dart';
import 'core/storage_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Trava a tela em pé e esconde a barra de status
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

// "with TickerProviderStateMixin" é o segredo para animações suaves (60FPS)
class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  final GameEngine _engine = GameEngine();
  final SoundManager _soundManager = SoundManager();
  final StorageManager _storageManager = StorageManager();
  
  late Ticker _ticker; // Substitui o Timer para melhor performance

  bool _gameStarted = false;
  bool _gameOver = false;
  bool _isPaused = false;

  int _debugTapCount = 0;

  @override
  void initState() {
    super.initState();
    
    // 1. Inicializa Som e Score
    _soundManager.init();
    _loadHighScore();

    // 2. CONEXÃO DE EVENTOS (Lógica -> Som/Save)
    _engine.onShootEvent = _soundManager.playShoot;
    _engine.onExplosionEvent = _soundManager.playExplosion;
    
    // FALTAVA ISSO: Salvar o score quando a engine avisar
    _engine.onNewHighScoreEvent = (int newRecord) {
      _storageManager.saveHighScore(newRecord);
    };

    // 3. Configura o Game Loop (Ticker)
    _ticker = createTicker((elapsed) {
      if (_gameStarted && !_gameOver && !_isPaused) {
        // Roda a matemática do jogo
        bool playerDied = _engine.update();
        
        if (playerDied) {
          setState(() {
            _gameOver = true;
            _gameStarted = false;
          });
        } else {
          // Redesenha a tela (atualiza posições e a barra de cooldown)
          setState(() {}); 
        }
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
    _ticker.dispose(); // Para o relógio ao fechar
    _soundManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.body,
      body: SafeArea( // Evita que o jogo fique embaixo da câmera frontal (notch)
        child: Column(
          children: [
            // Tela LCD (Onde o jogo acontece)
            Expanded(
              flex: 5, // Dá mais espaço para a tela
              child: GameScreenLCD(
                engine: _engine, 
                gameStarted: _gameStarted, 
                gameOver: _gameOver,
                isPaused: _isPaused,
              ),
            ),
            
            // Logo "NaveBoy" com Debug Secreto
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
                    fontFamily: 'Courier', // Fonte mais retro
                    fontSize: 28
                  )
                ),
              ),
            ),

            // Controles
          Expanded(
            flex: 1,
            child: ControlPad(
              onStart: _startGame,
              onPause: _togglePause,
              onToggleDir: () => _engine.toggleDir(),
              onFire: () {
                if (_gameStarted && !_gameOver) _engine.fire();
              },
            ),
          ),
          ],
        ),
      ),
    );
  }
}