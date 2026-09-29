import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum ExpenseCategory {
  food(
    id: 'food',
    displayName: 'Food & Dining',
    icon: Icons.restaurant_rounded,
    color: AppColors.catFood,
  ),
  transportation(
    id: 'transportation',
    displayName: 'Transportation',
    icon: Icons.directions_car_rounded,
    color: AppColors.catTransport,
  ),
  shopping(
    id: 'shopping',
    displayName: 'Shopping',
    icon: Icons.shopping_bag_rounded,
    color: AppColors.catShopping,
  ),
  entertainment(
    id: 'entertainment',
    displayName: 'Entertainment',
    icon: Icons.movie_filter_rounded,
    color: AppColors.catEntertainment,
  ),
  bills(
    id: 'bills',
    displayName: 'Bills & Utilities',
    icon: Icons.receipt_long_rounded,
    color: AppColors.catBills,
  ),
  health(
    id: 'health',
    displayName: 'Health & Medical',
    icon: Icons.medical_services_rounded,
    color: AppColors.catHealth,
  ),
  education(
    id: 'education',
    displayName: 'Education',
    icon: Icons.school_rounded,
    color: AppColors.catEducation,
  ),
  travel(
    id: 'travel',
    displayName: 'Travel & Trips',
    icon: Icons.flight_takeoff_rounded,
    color: AppColors.catTravel,
  ),
  personal(
    id: 'personal',
    displayName: 'Personal Care',
    icon: Icons.spa_rounded,
    color: AppColors.catPersonal,
  ),
  investments(
    id: 'investments',
    displayName: 'Investments & Savings',
    icon: Icons.trending_up_rounded,
    color: AppColors.catInvestment,
  ),
  other(
    id: 'other',
    displayName: 'Other',
    icon: Icons.category_rounded,
    color: AppColors.catOther,
  );

  const ExpenseCategory({
    required this.id,
    required this.displayName,
    required this.icon,
    required this.color,
  });

  final String id;
  final String displayName;
  final IconData icon;
  final Color color;

  static ExpenseCategory fromId(String? id) {
    if (id == null) return ExpenseCategory.other;
    return ExpenseCategory.values.firstWhere(
      (cat) => cat.id.toLowerCase() == id.toLowerCase(),
      orElse: () => ExpenseCategory.other,
    );
  }
}
