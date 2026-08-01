import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppFontWeight {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}

class AppTextStyles {
  static final TextStyle headline1 = GoogleFonts.poppins(
    fontSize: 28, fontWeight: AppFontWeight.bold, color: AppColors.textPrimary, height: 1.3,
  );
  static final TextStyle headline2 = GoogleFonts.poppins(
    fontSize: 22, fontWeight: AppFontWeight.semiBold, color: AppColors.textPrimary, height: 1.3,
  );
  static final TextStyle title = GoogleFonts.poppins(
    fontSize: 18, fontWeight: AppFontWeight.semiBold, color: AppColors.textPrimary,
  );
  static final TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 16, fontWeight: AppFontWeight.medium, color: AppColors.textPrimary,
  );
  static final TextStyle body = GoogleFonts.inter(
    fontSize: 14, fontWeight: AppFontWeight.regular, color: AppColors.textSecondary, height: 1.5,
  );
  static final TextStyle bodyBold = GoogleFonts.inter(
    fontSize: 14, fontWeight: AppFontWeight.semiBold, color: AppColors.textPrimary,
  );
  static final TextStyle caption = GoogleFonts.inter(
    fontSize: 12, fontWeight: AppFontWeight.regular, color: AppColors.textHint,
  );
  static final TextStyle button = GoogleFonts.poppins(
    fontSize: 16, fontWeight: AppFontWeight.semiBold, color: Colors.white,
  );
  static final TextStyle price = GoogleFonts.poppins(
    fontSize: 20, fontWeight: AppFontWeight.bold, color: AppColors.primary,
  );
  static final TextStyle priceLarge = GoogleFonts.poppins(
    fontSize: 32, fontWeight: AppFontWeight.bold, color: AppColors.primary,
  );
}