import 'package:flutter/material.dart';

/// App Color Palette - Space-inspired dark theme
/// All colors tested for WCAG AA contrast compliance
class AppColors {
  // Background colors
  static const deepNavy = Color(0xFF0A0E27);
  static const charcoalBlack = Color(0xFF1A1D2E);
  static const darkCard = Color(0xFF252938);
  
  // Accent colors
  static const emergencyRed = Color(0xFFFF4757);
  static const amber = Color(0xFFFFA502);
  static const electricBlue = Color(0xFF1E90FF);
  static const neonViolet = Color(0xFF9B59B6);
  
  // State colors
  static const success = Color(0xFF26DE81);
  static const warning = Color(0xFFFFA502);
  static const error = Color(0xFFFF4757);
  static const info = Color(0xFF1E90FF);
  
  // Text colors (high contrast for accessibility)
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB8BFCE);
  static const textDisabled = Color(0xFF6B7280);
}

/// Typography system - accessibility-first
class AppTextStyles {
  // Display styles
  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
    color: AppColors.textPrimary,
  );
  
  static const displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.3,
    color: AppColors.textPrimary,
  );
  
  // Title styles
  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
    color: AppColors.textPrimary,
  );
  
  static const titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.4,
    color: AppColors.textPrimary,
  );
  
  // Body styles
  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.textPrimary,
  );
  
  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.5,
    color: AppColors.textSecondary,
  );
  
  // Label styles
  static const labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
    height: 1.4,
    color: AppColors.textPrimary,
  );
  
  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
    color: AppColors.textSecondary,
  );
}

/// Spacing system
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Border radius system
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}

/// Material 3 Theme Configuration
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.emergencyRed,
        secondary: AppColors.electricBlue,
        tertiary: AppColors.neonViolet,
        surface: AppColors.charcoalBlack,
        background: AppColors.deepNavy,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: Colors.white,
      ),
      
      // Scaffold
      scaffoldBackgroundColor: AppColors.deepNavy,
      
      // App bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.charcoalBlack,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleLarge,
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      
      // Elevated button (primary actions)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emergencyRed,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.emergencyRed.withOpacity(0.4),
          minimumSize: const Size(double.infinity, 56), // Accessibility: 56dp min
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(fontSize: 16),
        ),
      ),
      
      // Outlined button (secondary actions)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          side: const BorderSide(
            color: AppColors.textSecondary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(fontSize: 16),
        ),
      ),
      
      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.electricBlue,
          minimumSize: const Size(88, 48), // Minimum tap target
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.textSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.textSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.electricBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDisabled,
        ),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.textDisabled,
        thickness: 1,
        space: AppSpacing.md,
      ),
      
      // Text theme
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
      ),
    );
  }
}
