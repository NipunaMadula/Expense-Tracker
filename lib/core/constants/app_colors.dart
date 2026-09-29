import 'package:flutter/material.dart';

/// App color palette carefully curated for clean, modern aesthetics
/// adhering to Material 3 guidelines with rich contrast in both light and dark modes.
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryContainer = Color(0xFFEEF2FF);
  static const Color primaryContainerDark = Color(0xFF1E1B4B);

  // Secondary accent colors
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color secondaryLight = Color(0xFF22D3EE);
  static const Color accent = Color(0xFF10B981); // Emerald Green
  static const Color accentRose = Color(0xFFF43F5E); // Rose

  // Neutral tones - Light Mode
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Neutral tones - Dark Mode
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color surfaceVariantDark = Color(0xFF334155); // Slate 700
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color borderDark = Color(0xFF334155);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Category specific curated colors
  static const Color catFood = Color(0xFFF97316); // Orange
  static const Color catTransport = Color(0xFF3B82F6); // Blue
  static const Color catShopping = Color(0xFFEC4899); // Pink
  static const Color catEntertainment = Color(0xFF8B5CF6); // Purple
  static const Color catBills = Color(0xFF14B8A6); // Teal
  static const Color catHealth = Color(0xFFEF4444); // Red
  static const Color catEducation = Color(0xFF6366F1); // Indigo
  static const Color catTravel = Color(0xFF06B6D4); // Cyan
  static const Color catPersonal = Color(0xFF10B981); // Emerald
  static const Color catInvestment = Color(0xFF84CC16); // Lime
  static const Color catOther = Color(0xFF64748B); // Slate
}
