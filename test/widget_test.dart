// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spaceboy/main.dart';

void main() {
  // Configuração inicial para simular o armazenamento de dados
  setUpAll(() {
    SharedPreferences.setMockInitialValues({}); // Simula banco vazio
  });

  testWidgets('Smoke Test: Verifica se o Game Boy inicia corretamente', (WidgetTester tester) async {
    // 1. Carrega o App
    await tester.pumpWidget(const SpaceConsoleApp());

    // 2. Verifica se os elementos visuais estáticos estão lá
    expect(find.text('SPACEBOY'), findsOneWidget); // O Logo do console
    expect(find.text('PRESS BUTTON'), findsOneWidget); // O texto na tela LCD
    expect(find.text('A'), findsOneWidget); // O botão de tiro
    expect(find.text('START'), findsOneWidget);
    
    // O Score não deve aparecer antes do jogo começar
    expect(find.text('0'), findsNothing); 
  });

  testWidgets('Start Game: Botão A deve iniciar o jogo', (WidgetTester tester) async {
    await tester.pumpWidget(const SpaceConsoleApp());

    // 1. Toca no botão "A" (que agora inicia o jogo também)
    await tester.tap(find.text('A'));
    
    // 2. Atualiza os frames (pump) para processar o clique e o setState
    await tester.pump(); 

    // 3. Verifica se a tela mudou
    expect(find.text('PRESS BUTTON'), findsNothing); // Texto deve sumir
    expect(find.text('0'), findsOneWidget); // O Score (0) deve aparecer
    
    // Verifica se os corações (vidas) apareceram. 
    // Como são ícones, procuramos pelo IconData.
    expect(find.byIcon(Icons.favorite), findsWidgets); 
  });

  testWidgets('Pause System: Botão START deve pausar e despausar', (WidgetTester tester) async {
    await tester.pumpWidget(const SpaceConsoleApp());

    // 1. Inicia o jogo primeiro
    await tester.tap(find.text('A'));
    await tester.pump();

    // 2. Toca no START para Pausar
    await tester.tap(find.text('START'));
    await tester.pump();

    // Verifica se apareceu "PAUSED"
    expect(find.text('PAUSED'), findsOneWidget);

    // 3. Toca no START de novo para Despausar
    await tester.tap(find.text('START'));
    await tester.pump();

    // Verifica se "PAUSED" sumiu
    expect(find.text('PAUSED'), findsNothing);
  });
}
