import 'package:flutter/material.dart';
import 'app_colors.dart';

// TODO: Build out full ThemeData — typography, button styles, input decoration theme.
abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryNavy),
        scaffoldBackgroundColor: AppColors.backgroundAsh,
        useMaterial3: true,
      );
}
