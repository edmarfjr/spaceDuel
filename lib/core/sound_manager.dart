import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb e debugPrint

class SoundManager {
  // Criamos players dedicados
  final AudioPlayer _shootPlayer = AudioPlayer();
  final AudioPlayer _explodePlayer = AudioPlayer();

  Future<void> init() async {
    // Configura o player para baixa latência (importante para jogos)
    // O modo 'lowLatency' ajuda muito no Android e Web
    try {
      await _shootPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _explodePlayer.setPlayerMode(PlayerMode.lowLatency);
      
      // Pré-carrega os sons (Isso ajuda a evitar o lag no primeiro tiro)
      if (!kIsWeb) { 
        // No Android/iOS pré-carregamos. 
        // Na Web evitamos para não disparar erro de Autoplay cedo demais.
        await _shootPlayer.setSource(AssetSource('shoot.wav'));
        await _explodePlayer.setSource(AssetSource('explosion.wav'));
      }
    } catch (e) {
      debugPrint("Erro SoundManager init: $e");
    }
  }

  void playShoot() async {
    try {
      // NA WEB E MOBILE: Simplesmente manda tocar.
      // Se já estiver tocando, o comportamento padrão do AudioPlayer 
      // geralmente é reiniciar ou misturar dependendo da plataforma.
      // Removemos o .stop() para evitar travamentos na Web.
      
      if (_shootPlayer.state == PlayerState.playing) {
        // Tenta rebobinar para efeito de "metralhadora"
        await _shootPlayer.seek(Duration.zero); 
        await _shootPlayer.resume();
      } else {
        await _shootPlayer.play(AssetSource('shoot.mp3'), volume: 0.5);
      }
    } catch (e) {
      debugPrint("Erro ao tocar tiro: $e");
    }
  }

  void playExplosion() async {
    try {
      // Para explosão, sempre manda tocar por cima
      if (_explodePlayer.state == PlayerState.playing) {
        await _explodePlayer.seek(Duration.zero);
        await _explodePlayer.resume();
      } else {
        await _explodePlayer.play(AssetSource('explosion.mp3'), volume: 1.0);
      }
    } catch (e) {
      debugPrint("Erro ao tocar explosão: $e");
    }
  }

  void dispose() {
    _shootPlayer.dispose();
    _explodePlayer.dispose();
  }
}