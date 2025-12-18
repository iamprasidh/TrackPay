import 'package:flutter/material.dart';

/// Theme extension for semantic app colors that work in light and dark modes.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color income;
  final Color expense;
  final Color muted;

  const AppColors({
    required this.income,
    required this.expense,
    required this.muted,
  });

  @override
  AppColors copyWith({
    Color? income,
    Color? expense,
    Color? muted,
  }) {
    return AppColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      muted: muted ?? this.muted,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      income: Color.lerp(income, other.income, t) ?? income,
      expense: Color.lerp(expense, other.expense, t) ?? expense,
      muted: Color.lerp(muted, other.muted, t) ?? muted,
    );
  }
}