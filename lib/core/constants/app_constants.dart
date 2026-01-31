import 'package:flutter/material.dart';

/// ===============================
/// UI TOKENS (APP CLARO)
/// Paleta:
/// - Identidade: roxo profundo (accent/primary)
/// - Base: fundo claro (para leitura boa)
/// - Acentos semânticos: verde neon (ao vivo) e amarelo quente (destaque)
/// ===============================
class AppColors {
  // Fundo e superfícies (claros)
  static const Color bg = Color(0xFFF8F8F7);        // fundo geral
  static const Color surface = Colors.white;       // cards / painéis
  static const Color line = Color(0xFFE5E7EB);      // divisores

  // Texto
  static const Color ink = Color(0xFF101010);       // texto principal
  static const Color muted = Color(0xFF6B7280);     // texto secundário

  // Identidade
  static const Color accent = Color(0xFF6D28D9);    // roxo profundo (mantém nome antigo)
  static const Color primary = accent;              // alias opcional

  // Compatibilidade (login Apple etc.)
  static const Color apple = Color(0xFF111111);
}

/// ===============================
/// CORES SEMÂNTICAS (PRODUTO)
/// ===============================
class AppSemanticColors {
  /// Localização em tempo real
  static const Color live = Color(0xFF22C55E);      // verde neon

  /// Blocos em alta / atenção
  static const Color highlight = Color(0xFFFBBF24); // amarelo quente

  /// Emergência real
  static const Color danger = Color(0xFFEF4444);    // vermelho
}

class AppTheme {
  /// ColorScheme (LIGHT)
  static const ColorScheme colorScheme = ColorScheme.light(
    primary: AppColors.accent,
    secondary: AppSemanticColors.live,
    surface: AppColors.surface,
    error: AppSemanticColors.danger,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.ink,
    onError: Colors.white,
  );

  /// Tipografia
  static const TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: AppColors.ink,
    ),
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      height: 1.4,
      color: AppColors.ink,
    ),
    bodySmall: TextStyle(
      fontSize: 13,
      height: 1.35,
      color: AppColors.muted,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
  );

  /// Inputs
  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    hintStyle: const TextStyle(color: AppColors.muted),
    labelStyle: const TextStyle(color: AppColors.muted),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  );

  /// Botões
  static final ElevatedButtonThemeData elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );

  static final OutlinedButtonThemeData outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.ink,
      side: const BorderSide(color: AppColors.line),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );

  /// Cards
  static final CardThemeData cardTheme = CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: AppColors.line),
    ),
  );

  /// AppBar
  static const AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: AppColors.bg,
    foregroundColor: AppColors.ink,
    elevation: 0,
    centerTitle: false,
  );

  /// Tema final
  static ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: textTheme,
      inputDecorationTheme: inputDecorationTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      cardTheme: cardTheme,
      appBarTheme: appBarTheme,
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.accent,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
