import 'package:flutter/material.dart';

class GameConfig {
  static const double gravity = 0.2;
  static const double jetThrust = -0.5;
  static const double shipMaxVelocity = 15.0;
  static const double gameSpeed = 3.0;
  static const int fps = 60;
  static const int initialLives = 3; 
  static const int invulnerabilityFrames = 120;

  static const double shipWidth = 0.2;
  static const double shipHeight = 0.15;

  static const double enemyWidth = 0.25;
  static const double enemyHeight = 0.25;
  static const double enemySpeed = 0.015; // Velocidade vertical do inimigo

  static const double powerUpWidth = 0.15;
  static const double powerUpHeight = 0.15;
  
  // Reutilizamos o "Meteor" como bala, mas agora ele é um tiro menor
  static const double meteorSize = 0.04;

  static const double obstacleSize = 0.15;

  static const double bulletWidth = 0.05; 
  static const double bulletHeight = 0.02;

  static const int enemyBaseHp = 5;
}

class AppColors {
  static const Color body = Color(0xFFD0D0C0); // Bege GameBoy
  static const Color lcd = Color(0xFF8BAC0F);  // Verde LCD Fundo
  static const Color pixel = Color(0xFF0F380F); // Verde LCD Pixel (Escuro)
  static const Color obstacle = Color(0xFF2F4F2F);
  static const Color btnRed = Color(0xFFA82020);
  static const Color btnBlack = Colors.black;
}