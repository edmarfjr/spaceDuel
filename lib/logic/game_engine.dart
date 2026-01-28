import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/entities.dart';
import '../core/constants.dart';

class GameEngine {
  // Estado
  double shipY = 0;
  double shipVelocity = 0.008;
  int shipDir = 1; // 1 = para cima, -1 = para baixo
  int score = 0;
  int highScore = 0;
  int lives = 0;
  int shootTime = 120;
  int shootTimer = 0;

  static const bool enableSound = false;

  // Invencibilidade
  int _invulnerableTimer = 0; // Conta quantos frames faltam para acabar a imunidade
  bool get isInvulnerable => _invulnerableTimer > 0;

  late Enemy enemy;

  late PowerUp powerUp;

  List<GameObj> enemyBlts = [];
  List<GameObj> bullets = [];
  List<GameObj> obstaculos = [];
  List<Particle> particles = [];

  int level = 1;

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
    shipDir = 1;
    score = 0;
    lives = GameConfig.initialLives;
    shootTime = 120;
    _invulnerableTimer = 0;

    _spawnPowerUp();

    enemy = Enemy(
        x: 0.8,
        y: 0.0,
        vy: GameConfig.enemySpeed,
        life: 5,
        type: EnemyType.padrao,
        shootTimer: 100);

    enemyBlts.clear();
    bullets.clear();
    particles.clear();

    _generateObstacles();
  }

  void _spawnEnemy() {
    // A cada nível, o inimigo ganha +3 de vida
    int newHp = GameConfig.enemyBaseHp + ((level - 1) * 3);
    
    List<EnemyType> enemyTypes = EnemyType.values;
    EnemyType selectedType = enemyTypes[Random().nextInt(enemyTypes.length)];
    int nRajada = 0;
    if (selectedType == EnemyType.rajada) {
      nRajada = 1 + (level ~/ 3); // A cada 3 níveis, aumenta a rajada
    }

    enemy = Enemy(
      x: 0.8, 
      y: 0.0,
      life: newHp,
      lifeMax: newHp,
      type: selectedType,
      // Opcional: Aumentar velocidade vy com o nível
      vy: GameConfig.enemySpeed + (level * 0.001),
      burstCount: nRajada
    );
  }

  void _spawnPowerUp() {
    List<PowerUpType> powerUpTypes = PowerUpType.values;
    PowerUpType selectedType = powerUpTypes[Random().nextInt(powerUpTypes.length)];
    String message = "";
    switch (selectedType) {
      case PowerUpType.life:
        message = "+1 Vida!";
        break;
      case PowerUpType.speedBoost:
        message = "Velocidade +!";
        break;
      case PowerUpType.weaponUpgrade:
        message = "Tiro Rápido!";
        break;
    }
    powerUp = PowerUp(
      x: 0.8, 
      y: 0.0,
      type: selectedType,
      message: message
    );
  }

  // NOVO: Passar de Fase
  void _nextLevel() {
    level++; // Aumenta dificuldade
    score += 100; // Bônus por matar o boss
    
    // 1. Limpa a tela
    enemyBlts.clear();
    bullets.clear();
    // (Não limpamos partículas para deixar a explosão do boss aparecer)

    // 2. Novos Obstáculos
    _generateObstacles();

    // 3. Novo Inimigo
    _spawnEnemy();

    //if(level>1){
      _spawnPowerUp();
    //}
  }

  void _generateObstacles() {
    obstaculos.clear();
    Random r = Random();
    int count = r.nextInt(3) + 1; // 2, 3, 4 ou 5
    
    for (int i = 0; i < count; i++) {
      // X entre -0.3 e 0.3 (meio da tela)
      double randX = (r.nextDouble() * 0.6) - 0.3;
      // Y entre -0.8 e 0.8
      double randY = (r.nextDouble() * 1.6) - 0.8;
      
      obstaculos.add(GameObj(x: randX, y: randY));
    }
  }

  // Atualizar Física (chamado a cada frame)
  // Retorna TRUE se houve colisão (Game Over)
  bool update() {
    _updateShip();
    _updateEnemy();
    _updatePowerUp();
    _updateEnemyBullets();
    _updateBullets();
    _updateParticles();

    enemyBlts.removeWhere((m) => m.isDead);
    bullets.removeWhere((b) => b.isDead);

    return _checkCollisions();
  }

  void toggleDir() {
    shipDir = shipDir * -1;
  }

  void fire() {
    if (shootTimer > 0) return; // Espera o cooldown
    bullets.add(GameObj(x: -0.8, y: shipY, vx: 0.025, vy: 0));
    shootTimer = shootTime; // Cooldown de 120 frames (2 segundos a 60fps)
    if (enableSound) onShootEvent?.call();
  }

   void _updatePowerUp() {

    if (powerUp.isCollected==false) {
      // 1. Movimento Vertical (Bounce)
      powerUp.y += powerUp.vy;
      
      // Se bateu em cima ou em baixo, inverte a direção
      if (powerUp.y < -0.9 || powerUp.y > 0.9) {
        powerUp.vy = -powerUp.vy;
        // Correção de posição para não ficar preso na parede
        powerUp.y = powerUp.y.clamp(-0.9, 0.9);
      }
      // 2. Timer de vida
      powerUp.timer--;
      if (powerUp.timer <= 0) {
        _enemyFire(x: powerUp.x - 0.1, y: powerUp.y, isFragmenting: false);
        powerUp.isCollected = true; // Remove o powerup da tela
        powerUp.x = 2.0;
      }

    } else {
        powerUp.collectedTimer--;
        if (powerUp.collectedTimer <= 0) {
          //powerUp.isCollected = false;
          powerUp.x = 2.0; // Remove o powerup da tela
        }
      }
   }
  void _updateEnemy() {
      // 1. Movimento Vertical (Bounce)
      enemy.y += enemy.vy;
      
      // Se bateu em cima ou em baixo, inverte a direção
      if (enemy.y < -0.9 || enemy.y > 0.9) {
        enemy.vy = -enemy.vy;
        // Correção de posição para não ficar preso na parede
        enemy.y = enemy.y.clamp(-0.9, 0.9);
      }

      // 2. Lógica de Tiro (A cada 60 frames / 1 segundo aprox)
      enemy.shootTimer++;
      switch (enemy.type) {
      case EnemyType.padrao:
        if (enemy.shootTimer > 60) { // 1 tiro por segundo
          _enemyFire(x: enemy.x - 0.1, y: enemy.y, isFragmenting: false);
          enemy.shootTimer = 0;
        }
        break;

      case EnemyType.fragmenta:
        if (enemy.shootTimer > 90) { // Tiro mais lento (1.5s)
          _enemyFire(x: enemy.x - 0.1, y: enemy.y, isFragmenting: true);
          enemy.shootTimer = 0;
        }
        break;

      case EnemyType.rajada:
        // Lógica de Rajada
        if (enemy.shootTimer > 40) { // Intervalo entre rajadas
           _enemyFire(x: enemy.x - 0.1, y: enemy.y, isFragmenting: false);
           enemy.burstCount++;
           
           if (enemy.burstCount < 3) {
             enemy.shootTimer = 30; // 30 frames para o próximo tiro DA RAJADA (rápido)
           } else {
             enemy.burstCount = 0;
             enemy.shootTimer = -20; // Pausa longa após a rajada
           }
        }
        break;
    }
  }

  void _enemyFire({required double x,required double y,required bool isFragmenting}) {
    double dx = -0.8 - enemy.x;
    double dy = shipY - enemy.y;
    double distance = sqrt(dx*dx + dy*dy);
    double speed = 0.015;

    enemyBlts.add(GameObj(
      x: x,
      y: y,
      vx: (dx / distance) * speed,
      vy: 0, // (dy / distance) * speed,
      canSplit: isFragmenting, // Define se vai fragmentar
    ));
    // Som opcional aqui
  }

  void _updateShip() {
    
    shipY += shipVelocity * shipDir;

    // Limites de tela
    if (shipY < -0.9) {
      shipDir = 1;
    } else if (shipY > 0.9) {
      shipDir = -1;
    }
    if (_invulnerableTimer > 0) {
      _invulnerableTimer--;
    }
    if (shootTimer > 0) {
      shootTimer--;
    }
  }

  void _updateEnemyBullets() {
    // Precisamos de uma lista temporária para adicionar os fragmentos
    // pois não podemos adicionar na lista que estamos iterando
    List<GameObj> newFragments = [];

    for (var b in enemyBlts) {
      if (b.isDead) continue;
      b.x += b.vx;
      b.y += b.vy;

      // LÓGICA DE FRAGMENTAÇÃO
      // Se for fragmentável, não tiver fragmentado, e passar do meio da tela (x < 0)
      if (b.canSplit && !b.hasSplit && b.x < -0.2) { 
        b.hasSplit = true;
        b.isDead = true; // O projétil "mãe" some

        // Cria 3 fragmentos em leque
        // 1. Meio (continua a trajetória original)
        newFragments.add(GameObj(x: b.x, y: b.y, vx: b.vx * 1, vy: b.vy));
        
        // 2. Cima (Desvia um pouco o vy para cima)
        newFragments.add(GameObj(x: b.x, y: b.y, vx: b.vx * 1, vy: b.vy - 0.015));

        // 3. Baixo (Desvia um pouco o vy para baixo)
        newFragments.add(GameObj(x: b.x, y: b.y, vx: b.vx * 1, vy: b.vy + 0.015));
        
        // Efeito visual
        _createExplosion(b.x, b.y);
      }
    }

    // Adiciona os fragmentos gerados à lista principal
    enemyBlts.addAll(newFragments);

    // Remove quem saiu da tela
    if (enemyBlts.isNotEmpty) {
      // Lógica simplificada de limpeza
      enemyBlts.removeWhere((b) => b.x < -1.5 || b.y < -1.5 || b.y > 1.5);
    }
  }
  void _updateBullets() {
    for (var bullet in bullets) {
      if (bullet.isDead) continue;
      bullet.x += bullet.vx;
      bullet.y += bullet.vy;
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
    // A. Colisão Tiros Jogador vs Obstáculos
    for (var pBullet in bullets) {
      if (pBullet.isDead) continue;
      for (var obs in obstaculos) {
        if (checkOverlap(pBullet.x, pBullet.y, GameConfig.bulletWidth, GameConfig.bulletHeight,
                         obs.x, obs.y, GameConfig.obstacleSize, GameConfig.obstacleSize)) {
          pBullet.isDead = true; // Tiro morre
          _createExplosion(pBullet.x, pBullet.y); // Efeito visual de batida
          // Obstáculo indestrutível, não faz nada com ele
          break;
        }
      }
    }

    // B. Colisão Tiros Inimigo vs Obstáculos
    for (var eBullet in enemyBlts) {
      if (eBullet.isDead) continue;
      for (var obs in obstaculos) {
        if (checkOverlap(eBullet.x, eBullet.y, GameConfig.meteorSize, GameConfig.meteorSize,
                         obs.x, obs.y, GameConfig.obstacleSize, GameConfig.obstacleSize)) {
          eBullet.isDead = true;
          _createExplosion(eBullet.x, eBullet.y);
          break;
        }
      }
    }
    
    for (var eb in enemyBlts) {
      if (eb.isDead) continue; 

      // 1. Colisão Nave
      bool hitShip = checkOverlap(
        -0.8, shipY, GameConfig.shipWidth, GameConfig.shipHeight,
        eb.x, eb.y, GameConfig.meteorSize, GameConfig.meteorSize
      );

      if (hitShip) {
        if (!isInvulnerable) {
          lives = max(0, lives - 1);
          _invulnerableTimer = GameConfig.invulnerabilityFrames;
          _createExplosion(-0.8, shipY);
          if (enableSound) onExplosionEvent?.call();
          
          eb.isDead = true;

          if (lives <= 0) {
            if (score > highScore) {
              highScore = score;
              onNewHighScoreEvent?.call(highScore);
            }
            return true; // Game Over
          }
        }
      }
    }
    // 2. Colisão Tiro
      for (var bullet in bullets) {
        if (bullet.isDead) continue; 

        bool hitBullet = checkOverlap(
          bullet.x, bullet.y, GameConfig.bulletWidth, GameConfig.bulletHeight,
          enemy.x, enemy.y, GameConfig.enemyWidth, GameConfig.enemyHeight
        );

        bool hitPup = checkOverlap(
          bullet.x, bullet.y, GameConfig.bulletWidth, GameConfig.bulletHeight,
          powerUp.x, powerUp.y, GameConfig.powerUpWidth, GameConfig.powerUpHeight
        );

        if (hitPup) {
          // Aplica o efeito do PowerUp
          switch (powerUp.type) {
            case PowerUpType.life:
              lives += 1;
              break;
            case PowerUpType.speedBoost:
              shipVelocity +=  0.001; 
              break;
            case PowerUpType.weaponUpgrade:
              shootTime = max(30, shootTime - 30); // Reduz o tempo de tiro, mínimo 30 frames
              break;
          }
          _createExplosion(powerUp.x, powerUp.y);
          powerUp.isCollected = true; // Remove o powerup da tela
          bullet.isDead = true;
          break;
        }

        if (hitBullet) {
          _createExplosion(enemy.x, enemy.y);
          if (enableSound) onExplosionEvent?.call();
          
          enemy.life -= 1;
          bullet.isDead = true;
          
          score += 5;

          // Verifica se matou
          if (enemy.life <= 0) {
            _createExplosion(enemy.x, enemy.y); // Explosão extra pela morte
            _createExplosion(enemy.x + 0.1, enemy.y + 0.1);
            _createExplosion(enemy.x - 0.1, enemy.y - 0.1);
            
            _nextLevel(); // <--- CHAMA A MUDANÇA DE FASE
          }
          break;
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
