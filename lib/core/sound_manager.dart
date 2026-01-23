import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundManager {
  final AudioPlayer _shootPlayer = AudioPlayer();
  final AudioPlayer _explodePlayer = AudioPlayer();

  Future<void> init() async {
    // REMOVEMOS toda aquela configuração de AudioContext complexa.
    // Deixe o padrão do sistema atuar.
    
    // Opcional: Pré-carregar os sons para evitar lag na primeira vez
    // (Apenas se os arquivos estiverem corretamente na pasta assets do FlutLab)
    try {
      await _shootPlayer.setSource(AssetSource('shoot.wav'));
      await _explodePlayer.setSource(AssetSource('explosion.wav'));
    } catch (e) {
      debugPrint("Erro no pré-carregamento: $e");
    }
  }

  void playShoot() {
    // Sem 'await'. Dispara e esquece.
    _shootPlayer.stop().then((_) {
      _shootPlayer.play(AssetSource('shoot.wav'), volume: 0.5);
    }).catchError((e) => debugPrint("Erro shoot: $e"));
  }

  void playExplosion() {
    // Tenta tocar por cima se possível, ou para e toca de novo
    if (_explodePlayer.state == PlayerState.playing) {
      _explodePlayer.stop().then((_) {
        _explodePlayer.play(AssetSource('explosion.wav'), volume: 1.0);
      });
    } else {
      _explodePlayer.play(AssetSource('explosion.wav'), volume: 1.0)
        .catchError((e) => debugPrint("Erro explosion: $e"));
    }
  }

  void dispose() {
    _shootPlayer.dispose();
    _explodePlayer.dispose();
  }
}