import 'dart:math';

class GameObj {
  double x;
  double y;
  double vx;
  double vy;

  bool isWave;       // É um tiro de onda?
  double initialY;   // O eixo central da onda
  double time;       // Tempo de vida (para calcular o seno)
  bool waveInverted; // Se true, faz a onda espelhada (seno negativo)
  bool isHoming;
  int currentLife; // Contador de vida
  int maxLife;     // Vida máxima


  bool canSplit;
  bool hasSplit;
  bool isDead = false;
  GameObj({
    required this.x,
    required this.y,  
    this.vx=0,  
    this.vy=0, 
    this.canSplit = false, 
    this.hasSplit = false,
    this.isWave = false,
    this.initialY = 0,
    this.time = 0,
    this.waveInverted = false,
    this.isHoming = false,
    this.currentLife = 0,
    this.maxLife = 0,
  });
}

enum EnemyType { 
  padrao, 
  rajada, 
  fragmenta,
  wave,
  homing, 
  laser,
}

enum LaserState {
  idle,     // Esperando
  charging, // Mirando (Aviso visual)
  firing    // ATIRANDO (Dano real)
}

class Enemy {
  double x;
  double y;
  double vy;
  bool isDead = false;
  int deadTmr = 120;
  int life;
  int lifeMax;
  EnemyType type;

  // NOVOS CAMPOS PARA O LASER
  LaserState laserState;
  int laserTimer; // Controla o tempo de cada fase (charge/fire)

  int shootTimer;
  int burstCount;

  Enemy({
    required this.x,
    required this.y,
    required this.vy,
    this.life = 2,
    this.lifeMax = 2,
    this.type = EnemyType.padrao,
    this.shootTimer = 0,
    this.burstCount = 0,
    this.laserState = LaserState.idle,
    this.laserTimer = 0,
  });
}

class Particle {
  double x;
  double y;
  double vx; // Velocidade X
  double vy; // Velocidade Y
  int life;  // Tempo de vida (frames)

  Particle({
    required this.x, 
    required this.y, 
    required this.vx, 
    required this.vy, 
    this.life = 20 // Dura 20 frames (aprox 0.3 segundos)
  });
}

enum PowerUpType {
  life,
  speedBoost,
  weaponUpgrade,
  bulletSpeed,
}

class PowerUp {
  double x;
  double y;
  double vy;
  bool isCollected = false;
  int collectedTimer = 120;
  int timer = 1800; // Dura 30 segundos se não coletado
  PowerUpType type;
  String message;
  PowerUp({required this.x, required this.y, required this.type, this.vy = 0.005, required this.message});
}

class NPC {
  double x;
  double y;
  double speed;
  bool isDead = false;

  // Lógica de Movimento
  double targetX; // Próximo waypoint X
  double targetY; // Próximo waypoint Y
  double finalY;  // Destino final (topo ou fundo da tela)
  
  NPC({
    required this.x,
    required this.y,
    required this.finalY,
    this.speed = 0.005, // Velocidade lenta
  }) : targetX = x, targetY = y {
    pickNextWaypoint(); // Já nasce escolhendo para onde ir
  }

  void pickNextWaypoint() {
    // Escolhe um X aleatório na tela (-0.8 a 0.8)
    targetX = (Random().nextDouble() * 1.6) - 0.8;

    // Avança um pouco no Y em direção ao destino final
    // Se estiver indo para baixo (finalY > y), soma. Se indo para cima, subtrai.
    double step = 0.3; 
    if (finalY > y) {
      targetY = y + step;
    } else {
      targetY = y - step;
    }
  }
}