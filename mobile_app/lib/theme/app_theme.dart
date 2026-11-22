import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Palet warna gelap HEALTHMAXXING.
///
/// Latar belakang memakai near-black, bukan hitam murni, supaya kartu,
/// border, dan bayangan tetap terlihat tanpa membuat mata cepat lelah.
class AppColors {
  AppColors._();

  static const Color backgroundTop = Color(0xFF0B0F14);
  static const Color backgroundBottom = Color(0xFF121A24);
  static const Color surface = Color(0xFF151C24);
  static const Color surfaceAlt = Color(0xFF1C2530);
  static const Color border = Color(0xFF2B3644);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color accent = Color(0xFF64FFDA);
  static const Color warning = Color(0xFFFFD08A);
  static const Color danger = Color(0xFFF09595);
  static const Color success = Color(0xFF4ADE80);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundTop, backgroundBottom],
  );

  static const BoxDecoration backgroundDecoration = BoxDecoration(
    gradient: backgroundGradient,
  );
}

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    onSecondary: Colors.black,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    error: AppColors.danger,
    onError: Colors.black,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.backgroundTop,
    canvasColor: AppColors.backgroundTop,
    cardColor: AppColors.surface,
    dividerColor: AppColors.border,
    splashColor: AppColors.accent.withValues(alpha: 0.12),
    highlightColor: Colors.white.withValues(alpha: 0.04),
    appBarTheme: const AppBarThemeData(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      modalBackgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: AppColors.surfaceAlt,
      labelStyle: const TextStyle(color: AppColors.textMuted),
      hintStyle: const TextStyle(color: AppColors.textMuted),
      prefixIconColor: AppColors.textMuted,
      suffixIconColor: AppColors.textMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      errorStyle: const TextStyle(color: AppColors.danger),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surfaceAlt,
      contentTextStyle: TextStyle(color: AppColors.textPrimary),
      actionTextColor: AppColors.accent,
      behavior: SnackBarBehavior.floating,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.accent;
        }
        return Colors.transparent;
      }),
      checkColor: const WidgetStatePropertyAll(Colors.black),
      side: const BorderSide(color: AppColors.textMuted, width: 1.5),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.4);
        }
        return AppColors.surfaceAlt;
      }),
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: AppColors.surfaceAlt,
      headerForegroundColor: AppColors.textPrimary,
      dayForegroundColor: WidgetStatePropertyAll(AppColors.textPrimary),
      yearForegroundColor: WidgetStatePropertyAll(AppColors.textPrimary),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
      linearTrackColor: AppColors.border,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.accent,
      selectionColor: AppColors.accent.withValues(alpha: 0.3),
      selectionHandleColor: AppColors.accent,
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.surfaceAlt,
        disabledForegroundColor: AppColors.textMuted,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.accent),
    ),
  );
}
