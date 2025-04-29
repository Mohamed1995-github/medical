import 'package:flutter/material.dart';

// Couleurs principales de l'application
const Color primaryColor = Color(0xFF3F51B5);
const Color accentColor = Color(0xFF536DFE);
const Color textColor = Color(0xFF212121);
const Color lightTextColor = Color(0xFF757575);
const Color dividerColor = Color(0xFFBDBDBD);
const Color errorColor = Color(0xFFE53935);
const Color successColor = Color(0xFF43A047);

// Thème principal de l'application
final ThemeData appTheme = ThemeData(
  primaryColor: primaryColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: accentColor,
    error: errorColor,
  ),
  textTheme: TextTheme(
    displayLarge:
        TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
    displayMedium:
        TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
    displaySmall:
        TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
    headlineMedium:
        TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
    headlineSmall:
        TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
    titleLarge:
        TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
    bodyLarge: TextStyle(fontSize: 16, color: textColor),
    bodyMedium: TextStyle(fontSize: 14, color: textColor),
    bodySmall: TextStyle(fontSize: 12, color: lightTextColor),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: dividerColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: errorColor),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      side: BorderSide(color: primaryColor),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  scaffoldBackgroundColor: Colors.white,
);
