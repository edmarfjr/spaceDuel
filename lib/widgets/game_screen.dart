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
        child: Stack(
          children: [
            // Nave
            Align(
              alignment: Alignment(-0.8, engine.shipY),
              child: Transform.rotate(
                angle: 1.57,
                child: const Icon(Icons.navigation, color: AppColors.pixel, size: 40),
              ),
            ),
            // Meteoros
            ...engine.meteors.map((m) => Align(
                  alignment: Alignment(m.x, m.y),
                  child: Container(
                    width: 25, height: 25,
                    decoration: const BoxDecoration(color: Color(0xFF306230), shape: BoxShape.circle),
                  ),
                )),
            //Renderiza as partículas da explosão
            ...engine.particles.map((p) => Align(
              alignment: Alignment(p.x, p.y),
              child: Container(
                width: 8, height: 8, // Pixelzinhos
                color: AppColors.pixel.withOpacity(p.life / 20), // Fade out
              ),
            )),
            // Tiros
            ...engine.bullets.map((b) => Align(
                  alignment: Alignment(b.x, b.y),
                  child: Container(width: 15, height: 5, color: AppColors.pixel),
                )),
            // UI
            if (!gameStarted) 
            Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("SPACEBOY", style: AppStyles.retro()),
                  const SizedBox(height: 10),
                  Text("PRESS BUTTON", style: AppStyles.retro(size: 20)),
                  const SizedBox(height: 20),
                  Text("HI SCORE: ${engine.highScore}", style: AppStyles.retro(size: 15)), // Mostra recorde no menu
                ],
              )),
            if (gameOver)
              Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text("GAME OVER", style: AppStyles.retro()),
                Text("PRESS BUTTON", style: AppStyles.retro(size: 20)),
                Text("Score: ${engine.score}", style: AppStyles.retro(size: 20)),
                if (engine.score >= engine.highScore && engine.score > 0)
                   Text("NEW RECORD!", style: AppStyles.retro(size: 15)),
              ])),
            if (isPaused && !gameOver && gameStarted)
               Center(child: Text("PAUSED", style: AppStyles.retro())),
            if (gameStarted)
              // Placar (Direita)
              Positioned(
                top: 10, right: 10, 
                child: Text("${engine.score}", style: AppStyles.retro(size: 24))
              ),
              if (gameStarted)
              Positioned(
                top: 40, right: 10, // Um pouco abaixo do score
                child: Text("HI ${engine.highScore}", style: AppStyles.retro(size: 15))
              ),
              // Corações / Vidas (Esquerda)
              Positioned(
                top: 10, left: 10,
                child: Row(
                  children: List.generate(engine.lives, (index) => const Padding(
                    padding: EdgeInsets.only(right: 4.0),
                    child: Icon(Icons.favorite, color: AppColors.pixel, size: 20),
                  )),
                ),
              ),
          ],
        ),
      ),
    );
  }
}