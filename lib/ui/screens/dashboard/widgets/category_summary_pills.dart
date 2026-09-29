import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/expense_category.dart';

class CategorySummaryPills extends StatelessWidget {
  const CategorySummaryPills({
    super.key,
    required this.categorySpending,
    required this.currencySymbol,
    required this.onCategoryTap,
  });

  final Map<ExpenseCategory, double> categorySpending;
  final String currencySymbol;
  final void Function(ExpenseCategory category) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (categorySpending.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort categories by expenditure (highest first)
    final sortedEntries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Category Spending',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              'Tap to filter',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: sortedEntries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              final category = entry.key;
              final amount = entry.value;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onCategoryTap(category),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: isDark ? 0.18 : 0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: category.color.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            category.icon,
                            size: 14,
                            color: category.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: category.color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            CurrencyFormatter.format(amount, symbol: currencySymbol),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
