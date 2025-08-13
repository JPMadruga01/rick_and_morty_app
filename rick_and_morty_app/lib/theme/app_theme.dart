import 'package:flutter/material.dart';
import '../design/tokens.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: Tokens.bgDark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Tokens.cardBlue,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Tokens.textPrimary),
      bodySmall: TextStyle(color: Tokens.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color.fromRGBO(255, 255, 255, 0.08),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Tokens.radius),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
