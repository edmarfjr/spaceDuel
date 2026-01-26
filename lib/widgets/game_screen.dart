import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/styles.dart';
import '../logic/game_engine.dart';

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

                // 2. METEOROS
                // Agora sem FittedBox, o Container vai esticar para preencher a hitbox
                ...engine.meteors.map((m) => positionObject(
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