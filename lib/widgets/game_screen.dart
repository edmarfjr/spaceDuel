import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/styles.dart';
import '../logic/game_engine.dart';
import '../models/entities.dart';

class GameScreenLCD extends StatelessWidget {
  final GameEngine engine;
  final bool gameStarted;
  final bool gameOver;
  final bool isPaused;

  const GameScreenLCD({
    super.key,
    required this.engine,
    required this.gameStarted,
    required this.gameOver,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 40, 20, 10),
      decoration: BoxDecoration(
        color: AppColors.lcd,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(30),
            bottomLeft: Radius.circular(10)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(5, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenW = constraints.maxWidth;
            final double screenH = constraints.maxHeight;

            // --- FUNÇÃO CORRIGIDA ---
            Widget positionObject({
              required double x,
              required double y,
              required double w,
              required double h,
              required Widget child,
            }) {
              // Cálculos de pixel (Matemática de Coordenadas)
              final double pixelW = (w / 2.0) * screenW;
              final double pixelH = (h / 2.0) * screenH;
              final double centerX = ((x + 1) / 2) * screenW;
              final double centerY = ((y + 1) / 2) * screenH;
              final double left = centerX - (pixelW / 2);
              final double top = centerY - (pixelH / 2);

              return Positioned(
                left: left,
                top: top,
                width: pixelW,
                height: pixelH,
                child: Stack(
                  fit: StackFit.expand, // Manda o filho preencher todo o espaço da hitbox
                  children: [
                    // 1. O Desenho Real
                    // (Removemos o FittedBox daqui para não sumir com os containers)
                    child,
                    
                    // 2. A Borda de Debug (Se ativada)
                    if (engine.showHitboxes)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                  ],
                ),
              );
            }

            //DEFINIÇÃO DOS ÍCONES DO INIMIGO ---
            IconData getEnemyIcon() {
              switch (engine.enemy.type) {
                case EnemyType.rajada: 
                  return Icons.rocket; // Foguete pesado
                case EnemyType.fragmenta: 
                  return Icons.change_history; // Triângulo/Stealth
                default: 
                  return Icons.airplanemode_active; // Jato padrão
              }
            }

            //DEFINIÇÃO DOS ÍCONES DO POWERUP ---
            IconData getPowerUpIcon() {
              switch (engine.powerUp.type) {
                case PowerUpType.life: 
                  return Icons.favorite; // Coração
                case PowerUpType.speedBoost: 
                  return Icons.speed; // Velocidade
                case PowerUpType.weaponUpgrade: 
                  return Icons.stars; // Arma
                default: 
                  return Icons.question_mark; // Pergunta (fallback)
              }
            }

            return Stack(
              children: [
                // 1. NAVE
                // A Nave PRECISA de FittedBox porque é um Icon e queremos que ele escale
                if (!engine.isInvulnerable || DateTime.now().millisecondsSinceEpoch % 100 < 50)
                  positionObject(
                    x: -0.8, 
                    y: engine.shipY, 
                    w: GameConfig.shipWidth, 
                    h: GameConfig.shipHeight, 
                    child: FittedBox( // <--- FittedBox SÓ AQUI
                      fit: BoxFit.contain,
                      child: Transform.rotate(
                        angle: 1.57,
                        child: const Icon(Icons.navigation, color: AppColors.pixel),
                      ),
                    ),
                  ),
                  //obstaculos
                  ...engine.obstaculos.map((obs) => positionObject(
                  x: obs.x, y: obs.y, w: GameConfig.obstacleSize, h: GameConfig.obstacleSize,
                  child: Container(
                    decoration:const BoxDecoration(
                      color: AppColors.obstacle
                      //border: Border.all(color: AppColors.pixel, width: 2), // Borda para destacar
                      //borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(child: Icon(Icons.close, size: 10, color: Colors.black12)), // Detalhe visual (X)
                  ),
                )),
                //powerup
               if (gameStarted) // Só mostra se o jogo começou
                  positionObject(
                    x: engine.powerUp.x,
                    y: engine.powerUp.y,
                    w: GameConfig.powerUpWidth,
                    h: GameConfig.powerUpHeight,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(getPowerUpIcon(), color: AppColors.pixel),
                    ),
                  ),
                //inimigo
               if (gameStarted) // Só mostra se o jogo começou
                  positionObject(
                    x: engine.enemy.x,
                    y: engine.enemy.y,
                    w: GameConfig.enemyWidth,
                    h: GameConfig.enemyHeight,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Transform.rotate(
                        angle: -1.57, // Aponta para a esquerda
                        child: Icon(getEnemyIcon(), color: AppColors.pixel),
                      ),
                    ),
                  ),
                  // Desenhamos uma barra vermelha pequena em cima do inimigo
                if (gameStarted)
                  Positioned(
                    // Posição baseada na tela: X do inimigo convertido, um pouco acima (Y - algo)
                    left: ((engine.enemy.x + 1) / 2) * screenW - 20, // Centralizado aprox
                    top: ((engine.enemy.y + 1) / 2) * screenH - 30, // Acima da nave
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Colors.black26, width: 0.5)
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        // Calcula % de vida
                        widthFactor: (engine.enemy.life / engine.enemy.lifeMax).clamp(0.0, 1.0),
                        child: Container(color: AppColors.pixel),
                      ),
                    ),
                  ),
                // 2. METEOROS
                // Agora sem FittedBox, o Container vai esticar para preencher a hitbox
                ...engine.enemyBlts.map((m) => positionObject(
                  x: m.x, 
                  y: m.y, 
                  w: GameConfig.meteorSize, 
                  h: GameConfig.meteorSize, 
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF306230), 
                      shape: BoxShape.circle
                    ),
                  ),
                )),

                // 3. TIROS
                ...engine.bullets.map((b) => positionObject(
                  x: b.x, 
                  y: b.y, 
                  w: GameConfig.bulletWidth, 
                  h: GameConfig.bulletHeight, 
                  child: Container(color: AppColors.pixel),
                )),

                // 4. PARTÍCULAS
                ...engine.particles.map((p) {
                   final px = ((p.x + 1) / 2) * screenW;
                   final py = ((p.y + 1) / 2) * screenH;
                   return Positioned(
                     left: px, top: py,
                     child: Container(
                       width: 6, height: 6,
                       color: AppColors.pixel.withOpacity(p.life / 20),
                     ),
                   );
                }),

                // --- UI (Placar, Vidas, Textos) ---
                 if (gameStarted)
                Positioned(
                  top: 10, right: 10, 
                  child: Text("${engine.score}", style: AppStyles.retro(size: 24))
                ),
                if (gameStarted || gameOver)
                  Positioned(
                    top: 40, right: 10,
                    child: Text("HI ${engine.highScore}", style: AppStyles.retro(size: 15))
                  ),
                Positioned(
                  top: 10, left: 10,
                  child: Row(
                    children: List.generate(engine.lives, (index) => const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(Icons.favorite, color: AppColors.pixel, size: 20),
                    )),
                  ),
                ),

                if (!gameStarted) 
                  Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("SPACEBOY", style: AppStyles.retro()),
                      const SizedBox(height: 10),
                      Text("PRESS BUTTON", style: AppStyles.retro(size: 20)),
                      const SizedBox(height: 20),
                      Text("HI SCORE: ${engine.highScore}", style: AppStyles.retro(size: 15)),
                    ],
                  )),

                if (gameOver)
                  Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text("GAME OVER", style: AppStyles.retro()),
                    Text("Score: ${engine.score}", style: AppStyles.retro(size: 20)),
                    if (engine.score >= engine.highScore && engine.score > 0)
                       Text("NEW RECORD!", style: AppStyles.retro(size: 15)),
                  ])),
                
                if (isPaused && !gameOver && gameStarted)
                   Center(child: Text("PAUSED", style: AppStyles.retro())),
              ],
            );
          },
        ),
      ),
    );
  }
}