class GameObj {
  double x;
  double y;
  double speed;
  bool isDead = false;
  GameObj({required this.x, required this.y, required this.speed});
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