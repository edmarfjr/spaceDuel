import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';

class ControlPad extends StatelessWidget {
  final VoidCallback onStart; // Inicia o jogo
  final VoidCallback onPause; // Pausa o jogo
  final VoidCallback onToggleDir;
  final VoidCallback onFire;

  const ControlPad({
    super.key, 
    required this.onStart, 
    required this.onPause,
    required this.onToggleDir, 
    required this.onFire
  });
  void _vibrate() {
    // lightImpact: vibração sutil (tipo teclado)
    // mediumImpact: vibração mais seca (tipo colisão)
    HapticFeedback.lightImpact(); 
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Botão Jato (Esquerda)
          GestureDetector(
            onTap: () {
              onStart();
              onToggleDir();
              _vibrate();
            },
            //onTapDown: (_) { onStart(); onJet(true); _vibrate();},
            //onTapUp: (_) => onJet(false),
            //onTapCancel: () => onJet(false),
            child: _buildButton(size: 120, color: AppColors.btnBlack, icon: Icons.unfold_more),
          ),
          
          // --- ÁREA CENTRAL (SELECT / START) ---
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
               Row(
                 children: [
                   // Select (Decorativo)
                   //_buildPillButton(label: "SELECT", onTap: () {}),
                   const SizedBox(width: 20),
                   // Start (Pause / Play)
                   _buildPillButton(label: "START", onTap: onPause),
                 ],
               ),
               const SizedBox(height: 20),
            ],
          ),

          // Botão Tiro (Direita)
          GestureDetector(
           onTap: () {
              onStart();
              onFire();
              _vibrate();
            },
            child: _buildButton(size: 120, color: AppColors.btnRed, icon: Icons.gps_fixed),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para os botões redondos grandes (A e Direcional)
  Widget _buildButton({required double size, required Color color, IconData? icon, String? label}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Colors.black38, offset: Offset(2, 4), blurRadius: 4)],
      ),
      child: Center(
        child: icon != null 
          ? Icon(icon, color: Colors.grey, size: 40)
          : Text(label!, style: const TextStyle(color: Colors.white24, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- A FUNÇÃO QUE FALTAVA ---
  // Widget auxiliar para os botões "pílula" (Select/Start)
  Widget _buildPillButton({required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Transform.rotate(
            angle: -0.5, // Inclinação clássica
            child: Container(
              width: 60, height: 20,
              decoration: BoxDecoration(
                color: AppColors.btnBlack,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(1, 2), blurRadius: 2)],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Color(0xFF303080))),
      ],
    );
  }
}