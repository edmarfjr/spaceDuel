import 'package:flutter/material.dart';

class GameConfig {
  static const double gravity = 0.2;
  static const double jetThrust = -0.5;
  static const double shipMaxVelocity = 15.0;
  static const double gameSpeed = 3.0;
  static const int fps = 60;
  static const int initialLives = 3; 
  static const int invulnerabilityFrames = 120;

  static const double shipWidth = 0.12;
  static const double shipHeight = 0.12;

  static const double meteorSize = 0.10; 

  static const double bulletWidth = 0.05; 
  static const double bulletHeight = 0.02;
}

class AppColors {
  static const Color body = Color(0xFFD0D0C0); // Bege GameBoy
  static const Color lcd = Color(0xFF8BAC0F);  // Verde LCD Fundo
  static const Color pixel = Color(0xFF0F380F); // Verde LCD Pixel (Escuro)
  static const Color btnRed = Color(0xFFA82020);
  static const Color btnBlack = Colors.black;
}