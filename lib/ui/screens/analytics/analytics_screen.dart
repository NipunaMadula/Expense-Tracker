import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/theme_provider.dart';
import '../dashboard/widgets/category_pie_chart.dart';
import '../dashboard/widgets/month_selector.dart';
import '../dashboard/widgets/monthly_bar_chart.dart';
import '../expense_form/expense_form_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    final selectedMonthExpenses = expenseProvider.selectedMonthExpenses;
    final total = expenseProvider.totalSelectedMonthExpenses;
    final categoryMap = expenseProvider.categorySpendingMap;

    final sortedCategories = categoryMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            MonthSelector(
              selectedMonth: expenseProvider.selectedMonth,
              onPrevious: () => expenseProvider.previousMonth(),
              onNext: () => expenseProvider.nextMonth(),
              onReset: () => expenseProvider.resetToCurrentMonth(),
            ),
            const SizedBox(height: 16),

            // High level stat cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Total Spent',
                    value: CurrencyFormatter.format(total, symbol: themeProvider.currencySymbol),
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Daily Average',
                    value: CurrencyFormatter.format(
                      expenseProvider.averageDailyExpenseForMonth,
                      symbol: themeProvider.currencySymbol,
                    ),
                    icon: Icons.calendar_today_rounded,
                    iconColor: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (selectedMonthExpenses.isEmpty)
              EmptyStateView(
                title: 'No Data for this Month',
                message: 'Add some expenses to see visual spending charts and category breakdowns.',
                actionLabel: 'Add Expense',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
                  );
                },
              )
            else ...[
              // Pie Chart Card
              Text(
                'Category Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: CategoryPieChart(
                  categoryData: categoryMap,
                  currencySymbol: themeProvider.currencySymbol,
                ),
              ),
              const SizedBox(height: 24),

              // Category Ranking Progress Bars
              Text(
                'Spending by Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedCategories.length,
                  separatorBuilder: (_, __) => const Divider(height: 20),
                  itemBuilder: (context, index) {
                    final item = sortedCategories[index];
                    final cat = item.key;
                    final amt = item.value;
                    final pct = total > 0 ? (amt / total) : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: cat.color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(cat.icon, size: 16, color: cat.color),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                cat.displayName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(amt, symbol: themeProvider.currencySymbol),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(pct * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 6,
                            backgroundColor: isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariantLight,
                            valueColor: AlwaysStoppedAnimation<Color>(cat.color),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // 6 Month Trend Bar Chart
              Text(
                'Monthly Comparison (Last 6 Months)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: MonthlyBarChart(
                  monthlyData: expenseProvider.monthlySpendingTrends,
                  currencySymbol: themeProvider.currencySymbol,
                ),
              ),
              const SizedBox(height: 28),
            ],
          ],
        ),
      ),
    );
  }
}
