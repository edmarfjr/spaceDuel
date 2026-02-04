import 'package:flutter/material.dart';

class GameConfig {
  static const int fps = 60;
  static const int initialLives = 3; 
  static const int invulnerabilityFrames = 60;

  static const double shipWidth = 0.2;
  static const double shipHeight = 0.1;

  static const double enemyWidth = 0.25;
  static const double enemyHeight = 0.25;
  static const double enemySpeed = 0.006; // Velocidade vertical do inimigo
  // Configuração da Onda
  static const double waveAmplitude = 0.15; // Largura da onda (o quanto ela abre)
  static const double waveFrequency = 5.0;  // Velocidade da oscilação
  // Configuração do Teleguiado
  static const double homingSpeed = 0.015; // Um pouco mais lento que o tiro normal
  static const double homingTurnRate = 0.025; // 5% de correção de curso por frame (Agilidade)
  static const int homingLifeTime = 180; // Vive por 3 segundos (60fps * 3)
  // Configuração do Laser
  static const int laserChargeTime = 60; // 1 segundo carregando (aviso)
  static const int laserDuration = 90;   // 1.5 segundos atirando (perigo!)
  static const int laserCooldown = 120;  // 2 segundos descansando

  static const double powerUpWidth = 0.15;
  static const double powerUpHeight = 0.15;
  
  // Reutilizamos o "Meteor" como bala, mas agora ele é um tiro menor
  static const double meteorSize = 0.04;

  static const double obstacleSize = 0.15;

  static const double bulletWidth = 0.05; 
  static const double bulletHeight = 0.02;

  static const int enemyBaseHp = 2;
}

class AppColors {
  static const Color body = Color(0xFFD0D0C0); // Bege GameBoy
  static const Color lcd = Color(0xFF8BAC0F);  // Verde LCD Fundo
  static const Color pixel = Color(0xFF0F380F); // Verde LCD Pixel (Escuro)
  static const Color obstacle = Color(0xFF2F4F2F);
  static const Color btnRed = Color(0xFFA82020);
  static const Color btnBlack = Colors.black;
  static const Color laserEnemy = Color(0xFFE04040); // Vermelho para a nave
  static const Color laserBeam = Color(0xFFFF0000);  // O raio em si
  static const Color laserWarning = Color(0x55FF0000); // O aviso (transparente)
}