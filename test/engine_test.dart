import 'package:flutter_test/flutter_test.dart';
// Ajuste os imports para o seu projeto
import 'package:spaceboy/logic/game_engine.dart';
import 'package:spaceboy/core/constants.dart';

void main() {
  late GameEngine engine;

  setUp(() {
    engine = GameEngine();
    engine.reset(); // Garante estado limpo antes de cada teste
  });

  group('Física da Nave', () {
    test('Gravidade deve puxar a nave para baixo', () {
      // Estado inicial
      double initialY = engine.shipY; // É 0
      
      // Simula 1 frame sem apertar jato
      engine.activateJet(false);
      engine.update();

      // Y deve aumentar (no sistema do Alignment, positivo é para baixo)
      expect(engine.shipY, greaterThan(initialY));
    });

    test('Jato deve puxar a nave para cima', () {
      engine.activateJet(true); // Aperta o botão
      
      // Simula alguns frames para vencer a inércia inicial da gravidade
      for(int i=0; i<10; i++) engine.update();

      // Y deve ser negativo (para cima)
      expect(engine.shipY, lessThan(0));
    });

    test('Nave não deve sair da tela (Clamp)', () {
      // Força a nave muito pra baixo
      for(int i=0; i<1000; i++) {
        engine.activateJet(false);
        engine.update();
      }
      // Não pode passar de 1.0 (limite inferior da tela)
      expect(engine.shipY, closeTo(1.0, 0.01));
    });
  });

  group('Lógica de Jogo', () {
    test('Reset deve restaurar vidas', () {
      engine.lives = 1;
      engine.reset();
      expect(engine.lives, GameConfig.initialLives);
    });

    test('Score deve iniciar zerado', () {
      expect(engine.score, 0);
    });
  });
}