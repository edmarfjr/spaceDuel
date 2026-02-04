import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants.dart';

class ControlPad extends StatelessWidget {
  final VoidCallback onStart; // Inicia o jogo
  final VoidCallback onPause; // Pausa o jogo
  final VoidCallback onToggleDir;
  final VoidCallback onFire;
  final bool gameStarted;
  final bool debugMode;

  const ControlPad({
    super.key, 
    required this.onStart, 
    required this.onPause,
    required this.onToggleDir, 
    required this.onFire,
    this.gameStarted = false,
    this.debugMode = false,
  });
  void _vibrate() {
    // lightImpact: vibração sutil (tipo teclado)
    // mediumImpact: vibração mais seca (tipo colisão)
    HapticFeedback.lightImpact(); 
  }

  Widget _debugBorder(Widget child) {
    if (!debugMode) return child;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.redAccent, width: 2),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle tutorialStyle = const TextStyle(
      color: Color(0xFF303080), 
      fontSize: 16, 
      fontFamily: 'Courier', 
      fontWeight: FontWeight.bold
    );
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Botão mudar direção (Esquerda)
          Column(
            children: [GestureDetector(
            onTap: () {
              onStart();
              onToggleDir();
              _vibrate();
            },
            //onTapDown: (_) { onStart(); onJet(true); _vibrate();},
            //onTapUp: (_) => onJet(false),
            //onTapCancel: () => onJet(false),
            child: _debugBorder(_buildButton(size: 150, color: AppColors.btnBlack, icon: Icons.unfold_more)),
            
          ),const SizedBox(width: 90),
          Text('Change Direction', style: tutorialStyle,),
          
          ],
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
                   _debugBorder(_buildPillButton(label: "PAUSE", onTap: onPause)),
                 ],
               ),
               const SizedBox(height: 20),
            ],
          ),

          // Botão Tiro (Direita)
          Column(children: [
            GestureDetector(
              onTap: () {
              onStart();
              onFire();
              _vibrate();
            },
            child: _debugBorder(_buildButton(size: 150, color: AppColors.btnRed, icon: Icons.gps_fixed)),
            ),const SizedBox(width: 90),
          Text('Shoot', style: tutorialStyle,),
          ],)
          
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
              width: 70, height: 25,
              decoration: BoxDecoration(
                color: AppColors.btnBlack,
                borderRadius: BorderRadius.circular(15),
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