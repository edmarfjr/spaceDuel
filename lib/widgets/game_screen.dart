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
  final VoidCallback? onToggleSound;

  const GameScreenLCD({
    super.key,
    required this.engine,
    required this.gameStarted,
    required this.gameOver,
    required this.isPaused,
    this.onToggleSound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 40, 20, 30),
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
              double visualScale = 2.5,
            }) {
              // Cálculos de pixel (Matemática de Coordenadas)
              final double pixelW = (w / 2.0) * screenW;
              final double pixelH = (h / 2.0) * screenH;
              final double centerX = ((x + 1) / 2) * screenW;
              final double centerY = ((y + 1) / 2) * screenH;
              final double left = centerX - (pixelW / 2);
              final double top = centerY - (pixelH / 2);

              return Positioned(
                left: left, top: top, width: pixelW, height: pixelH,
                child: Stack(
                  clipBehavior: Clip.none, // Permite que o ícone "vaze" para fora da hitbox
                  alignment: Alignment.center,
                  children: [
                    // 1. O DESENHO (Visualmente Aumentado)
                    // Usamos o Transform.scale para aumentar o ícone sem mexer na posição lógica
                    Transform.scale(
                      scale: visualScale, 
                      child: child,
                    ),

                    // 2. A HITBOX DE DEBUG (Tamanho Real Físico)
                    // Ela continua desenhando exatamente o tamanho pixelW / pixelH
                    if (engine.showHitboxes) 
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1)
                        )
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
                case EnemyType.wave: 
                  return Icons.blur_on;
                case EnemyType.homing: 
                  return Icons.gps_fixed;
                case EnemyType.laser: 
                  return Icons.camera;
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
                  return Icons.double_arrow; // Velocidade
                case PowerUpType.weaponUpgrade: 
                  return Icons.stars; // Arma
                case PowerUpType.bulletSpeed:
                  return Icons.bolt; // Velocidade da bala
                default: 
                  return Icons.question_mark; // Pergunta (fallback)
              }
            }

            // Lista de ícones para os obstáculos (Construções)
            final List<IconData> buildingIcons = [
              Icons.forest,
              Icons.location_city,
              Icons.apartment,
              Icons.store,
              Icons.terrain,
            ];

            return Stack(
              children: [
                // 1. NAVE
                // A Nave PRECISA de FittedBox porque é um Icon e queremos que ele escale
                if (gameStarted && (!engine.isInvulnerable || DateTime.now().millisecondsSinceEpoch % 100 < 50))
                  positionObject(
                    x: -0.8, 
                    y: engine.shipY, 
                    w: GameConfig.shipWidth , 
                    h: GameConfig.shipHeight , 
                    child: FittedBox( // <--- FittedBox SÓ AQUI
                      fit: BoxFit.contain,
                      child: Transform.rotate(
                        angle: 1.57,
                        child: const Icon(Icons.navigation, color: AppColors.pixel),
                      ),
                    ),
                  ),
                  if (engine.shootTimer > 0)
                  Positioned(
                    // Posiciona um pouco à direita da nave (-0.65 no eixo X)
                    left: ((-0.65 + 1) / 2) * screenW, 
                    // Acompanha a altura da nave
                    top: ((engine.shipY + 1) / 2) * screenH - 15, // -15 para centralizar verticalmente
                    child: Container(
                      width: 4,     // Barra fina vertical
                      height: 30,   // Altura total
                      decoration: BoxDecoration(
                        color: Colors.black26, // Fundo escuro da barra
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: Colors.white30, width: 0.5)
                      ),
                      // FractionallySizedBox permite preencher % do pai
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter, // Esvazia de cima para baixo
                        heightFactor: engine.shootTimer / engine.shootTime, // % de preenchimento
                        child: Container(color: AppColors.pixel), // A cor Ciano
                      ),
                    ),
                  ),
                  //obstaculos
                  ...engine.obstaculos.map((obs) {
                  // Escolhe um ícone baseado no "DNA" (hash) do objeto para não ficar mudando aleatoriamente
                  final iconData = buildingIcons[obs.hashCode % buildingIcons.length];
                  
                  return positionObject(
                    x: obs.x, y: obs.y, 
                    w: GameConfig.obstacleSize, h: GameConfig.obstacleSize, 
                    visualScale: 1.5, 
                    child: Icon(iconData, color: AppColors.obstacle, size: 30) // Ícone de prédio
                  );
                }),
                //npcs
                ...engine.npcs.map((npc) => positionObject(
                  x: npc.x, y: npc.y, 
                  w: 0.15, h: 0.15, // Tamanho aproximado
                  visualScale: 1.3,
                  child: Container(
                    decoration: const BoxDecoration(
                      //shape: BoxShape.circle,
                     // boxShadow: [BoxShadow(color: AppColors.obstacle, blurRadius: 5)],
                    ),
                    child: const Icon(Icons.directions_run, color: AppColors.pixel, size: 24), // Carinha feliz
                  ),
                )),
                //powerup
               if (gameStarted && (engine.powerUp.isCollected || engine.powerUp.timer > 300 || DateTime.now().millisecondsSinceEpoch % 100 < 50)) // Só mostra se o jogo começou
                  positionObject(
                    x: engine.powerUp.x,
                    y: engine.powerUp.y,
                    w: GameConfig.powerUpWidth,
                    h: GameConfig.powerUpHeight,
                    child: engine.powerUp.isCollected 
                    ? FittedBox(
                        fit: BoxFit.contain,
                        child: Text(
                          engine.powerUp.message, 
                          style: AppStyles.retro(size: 24).copyWith(color: AppColors.pixel) 
                        ),
                      )
                    : FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(getPowerUpIcon(), color: AppColors.pixel),
                    ),
                  ),
                  // --- RENDERIZAÇÃO DO LASER ---
                if (gameStarted && engine.enemy.type == EnemyType.laser && engine.enemy.laserState != LaserState.idle)
                  Positioned(
                    // O laser vai da borda esquerda (-1) até o inimigo (enemy.x)
                    left: 0, 
                    right: ((1 - engine.enemy.x) / 2) * screenW + (GameConfig.enemyWidth/2 * screenW/2), // Gruda no inimigo
                    top: ((engine.enemy.y + 1) / 2) * screenH - (engine.enemy.laserState == LaserState.firing ? 20 : 2), // Ajusta altura
                    
                    child: Container(
                      height: engine.enemy.laserState == LaserState.firing ? 40 : 4, // Grosso se atirando, fino se mirando
                      decoration: BoxDecoration(
                        // Se estiver atirando, cor sólida brilhante. Se carregando, cor transparente piscante.
                        color: engine.enemy.laserState == LaserState.firing 
                            ? AppColors.pixel.withOpacity(0.8) 
                            : AppColors.obstacle.withOpacity(DateTime.now().millisecondsSinceEpoch % 200 > 100 ? 0.5 : 0.2), // Pisca pisca
                        
                        boxShadow: engine.enemy.laserState == LaserState.firing ? [
                          const BoxShadow(color: AppColors.obstacle, blurRadius: 15, spreadRadius: 5)
                        ] : null,
                        
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                      ),
                    ),
                  ),
                //inimigo
               if (gameStarted && engine.enemy.life > 0) // Só mostra se o jogo começou
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
                if (gameStarted && engine.enemy.life > 0) 
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
                  visualScale: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF306230), 
                      shape: m.isHoming ? BoxShape.rectangle : BoxShape.circle,
                    ),
                  ),
                )),

                // 3. TIROS
                ...engine.bullets.map((b) => positionObject(
                  x: b.x, 
                  y: b.y, 
                  w: GameConfig.bulletWidth, 
                  h: GameConfig.bulletHeight, 
                  visualScale: 1,
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
                  top: 5, right: 10, 
                  child: Text("score: ${engine.score}", style: AppStyles.retro(size: 24))
                ),
                if (engine.hit>0)
                Positioned(
                  top: 40, left: 10, 
                  child: Text("hit: ${engine.hit}", style: AppStyles.retro(size: 24))
                ),
                //if (gameStarted || gameOver)
                //  Positioned(
                //    top: 40, right: 10,
                //    child: Text("HI ${engine.highScore}", style: AppStyles.retro(size: 15))
                //  ),
                Positioned(
                  top: 10, left: 10,
                  child: Row(
                    children: List.generate(engine.lives, (index) => const Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Icon(Icons.favorite, color: AppColors.pixel, size: 20),
                    )),
                  ),
                ),

                if (!gameStarted && !gameOver) 
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
                    Text("HighScore: ${engine.highScore}", style: AppStyles.retro(size: 20)),
                    Text("Score: ${engine.score}", style: AppStyles.retro(size: 20)),
                    if (engine.score >= engine.highScore && engine.score > 0)
                       Text("NEW RECORD!", style: AppStyles.retro(size: 15)),
                    Text("Enemy beaten: ${engine.level-1}", style: AppStyles.retro(size: 20)),
                    Text("Hit Streak: ${engine.highHit}", style: AppStyles.retro(size: 20)),
                    
                  ])),
                
                if (isPaused && !gameOver && gameStarted)
                    Center(child: Text("PAUSED", style: AppStyles.retro())),
                   // O Botão de Mute
                   if (isPaused && !gameOver && gameStarted)
                    Positioned(
                      top:10,
                      left:0,
                      right:0,
                      child: Center( child:GestureDetector(
                      onTap: onToggleSound, // Chama a função passada pelo Main
                      child: Icon(
                              engine.enableSound ? Icons.volume_up : Icons.volume_off, 
                              color: AppColors.pixel,
                              size: 24
                            ),
                      ))
                    ),
                    
              ],
            );
          },
        ),
      ),
    );
  }
}