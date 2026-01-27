class GameObj {
  double x;
  double y;
  double vx;
  double vy;
  bool canSplit;
  bool hasSplit;
  bool isDead = false;
  GameObj({required this.x, required this.y,  this.vx=0,  this.vy=0, this.canSplit = false, this.hasSplit = false});
}

enum EnemyType { 
  padrao, 
  rajada, 
  fragmenta 
}

class Enemy {
  double x;
  double y;
  double vy;
  bool isDead = false;
  int life;
  int lifeMax;
  EnemyType type;
  int shootTimer;
  int burstCount;
  Enemy({
    required this.x,
    required this.y,
    required this.vy,
    this.life = 5,
    this.lifeMax = 5,
    this.type = EnemyType.padrao,
    this.shootTimer = 0,
    this.burstCount = 0,
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
}

class PowerUp {
  double x;
  double y;
  double vy = 0.005;
  bool isCollected = false;
  PowerUpType type;
  PowerUp({required this.x, required this.y, required this.type});
}