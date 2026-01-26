import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/entities.dart';
import '../core/constants.dart';

class GameEngine {
  // Estado
  double shipY = 0;
  double shipVelocity = 0;
  int score = 0;
  int highScore = 0;
  int lives = 0;
  bool isJetActive = false;

  static const bool enableSound = false;

  // Invencibilidade
  int _invulnerableTimer =
      0; // Conta quantos frames faltam para acabar a imunidade
  bool get isInvulnerable => _invulnerableTimer > 0;

  List<GameObj> meteors = [];
  List<GameObj> bullets = [];
  List<Particle> particles = [];

  VoidCallback? onShootEvent;
  VoidCallback? onExplosionEvent;
  VoidCallback? onDamageEvent;

  Function(int)? onNewHighScoreEvent;

  //Variável para controlar o modo debug
  bool showHitboxes = false; 

  // Método para alternar o modo debug
  void toggleDebugMode() {
    showHitboxes = !showHitboxes;
  }

  // Reiniciar
  void reset() {
    shipY = 0;
    shipVelocity = 0;
    score = 0;
    lives = GameConfig.initialLives;
    _invulnerableTimer = 0;
    meteors.clear();
    bullets.clear();
  }

  // Atualizar Física (chamado a cada frame)
  // Retorna TRUE se houve colisão (Game Over)
  bool update() {
    _updateShip();
    _updateMeteors();
    _updateBullets();
    _updateParticles();
    if (_invulnerableTimer > 0) {
      _invulnerableTimer--;
    }

    meteors.removeWhere((m) => m.isDead);
    bullets.removeWhere((b) => b.isDead);

    return _checkCollisions();
  }

  void activateJet(bool isActive) {
    isJetActive = isActive;
  }

  void fire() {
    bullets.add(GameObj(x: -0.8, y: shipY, speed: 0.05));
    if (enableSound) onShootEvent?.call();
  }

  // --- Lógica Interna ---

  void _updateShip() {
    if (isJetActive) {
      shipVelocity += GameConfig.jetThrust;
    } else {
      shipVelocity += GameConfig.gravity;
    }

    shipVelocity = shipVelocity.clamp(
        -GameConfig.shipMaxVelocity, GameConfig.shipMaxVelocity);
    shipY += shipVelocity * 0.005;

    // Limites de tela
    if (shipY < -0.9) {
      shipY = -0.9;
      shipVelocity = 0;
    } else if (shipY > 0.9) {
      shipY = 0.9;
      shipVelocity = 0;
    }
  }

  void _updateMeteors() {
    for (var meteor in meteors) {
      if (meteor.isDead) continue;
      meteor.x -= meteor.speed * (1 + score / 50);
    }

    if (meteors.isNotEmpty && meteors.first.x < -1.5) {
      meteors.removeAt(0);
    }

    if (Random().nextInt(100) < 2) {
      meteors.add(
          GameObj(x: 1.5, y: (Random().nextDouble() * 2) - 1, speed: 0.02));
    }
  }

  void _updateBullets() {
    for (var bullet in bullets) {
      if (bullet.isDead) continue;
      bullet.x += bullet.speed;
    }
    bullets.removeWhere((bullet) => bullet.x > 1.5);
  }

  void _updateParticles() {
    for (var p in particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.life--;
    }
    particles.removeWhere((p) => p.life <= 0);
  }

  bool _checkCollisions() {
    bool checkOverlap(
        double x1, double y1, double w1, double h1, 
        double x2, double y2, double w2, double h2) {
      
      // Distância horizontal < Soma das metades das larguras
      bool overlapX = (x1 - x2).abs() < (w1 + w2) / 2;
      // Distância vertical < Soma das metades das alturas
      bool overlapY = (y1 - y2).abs() < (h1 + h2) / 2;

      return overlapX && overlapY;
    }
    for (var meteor in meteors) {
      if (meteor.isDead) continue; 

      // 1. Colisão Nave
      bool hitShip = checkOverlap(
        -0.8, shipY, GameConfig.shipWidth, GameConfig.shipHeight,
        meteor.x, meteor.y, GameConfig.meteorSize, GameConfig.meteorSize
      );

      if (hitShip) {
        if (!isInvulnerable) {
          lives = max(0, lives - 1);
          _invulnerableTimer = GameConfig.invulnerabilityFrames;
          _createExplosion(-0.8, shipY);
          if (enableSound) onExplosionEvent?.call();
          
          meteor.isDead = true;

          if (lives <= 0) {
            if (score > highScore) {
              highScore = score;
              onNewHighScoreEvent?.call(highScore);
            }
            return true; // Game Over
          }
        }
      }

      // 2. Colisão Tiro
      for (var bullet in bullets) {
        if (bullet.isDead) continue; 

        bool hitBullet = checkOverlap(
          bullet.x, bullet.y, GameConfig.bulletWidth, GameConfig.bulletHeight,
          meteor.x, meteor.y, GameConfig.meteorSize, GameConfig.meteorSize
        );

        if (hitBullet) {
          _createExplosion(meteor.x, meteor.y);
          if (enableSound) onExplosionEvent?.call();
          
          meteor.isDead = true;
          bullet.isDead = true;
          
          score += 5;
          break;
        }
      }
    }
    return false;
  }

  void _createExplosion(double x, double y) {
    Random r = Random();
    for (int i = 0; i < 4; i++) {
      particles.add(Particle(
          x: x,
          y: y,
          vx: (r.nextDouble() - 0.5) * 0.04, // Direção aleatória
          vy: (r.nextDouble() - 0.5) * 0.04));
    }
  }
}
