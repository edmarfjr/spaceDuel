import 'package:flutter/material.dart';
import 'constants.dart';

class AppStyles {
  static TextStyle retro({double size = 30}) {
    return TextStyle(
      color: AppColors.pixel,
      fontWeight: FontWeight.bold,
      fontSize: size,
      fontFamily: 'Courier',
      letterSpacing: 2.0,
    );
  }
}