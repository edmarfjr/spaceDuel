import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static const String _keyHighScore = 'high_score';

  // Salva o novo recorde
  Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHighScore, score);
  }

  // Carrega o recorde salvo (retorna 0 se não existir)
  Future<int> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyHighScore) ?? 0;
  }
}