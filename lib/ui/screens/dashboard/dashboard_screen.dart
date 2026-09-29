import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/theme_provider.dart';
import '../expense_detail/expense_detail_screen.dart';
import '../expense_form/expense_form_screen.dart';
import '../expense_list/widgets/expense_card.dart';
import 'widgets/category_pie_chart.dart';
import 'widgets/category_summary_pills.dart';
import 'widgets/month_selector.dart';
import 'widgets/monthly_bar_chart.dart';
import 'widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onNavigateToList,
  });

  final VoidCallback onNavigateToList;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    if (expenseProvider.isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Calculating your finances...'),
      );
    }

    if (expenseProvider.errorMessage != null && expenseProvider.allExpenses.isEmpty) {
      return Scaffold(
        body: ErrorStateView(
          message: expenseProvider.errorMessage!,
          onRetry: () => expenseProvider.refresh(),
        ),
      );
    }

    final selectedMonthExpenses = expenseProvider.selectedMonthExpenses;
    final recentExpenses = selectedMonthExpenses.take(4).toList();
    final greeting = _getGreeting();
    final userName = authProvider.user?.displayName ?? 'Welcome';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $userName 👋',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                letterSpacing: -0.3,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: expenseProvider.isUsingFirestore ? AppColors.success : AppColors.info,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  expenseProvider.isUsingFirestore ? 'Cloud Firestore Active' : 'Offline / Local Mode',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => themeProvider.toggleTheme(),
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => expenseProvider.refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

              // Total Expense Summary Card
              SummaryCard(
                totalAmount: expenseProvider.totalSelectedMonthExpenses,
                currencySymbol: themeProvider.currencySymbol,
                monthOverMonthPercentage: expenseProvider.monthOverMonthPercentage,
                monthlyBudget: themeProvider.monthlyBudget,
                onAddExpense: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Category Summary Pills (Quick filter & glance)
              if (expenseProvider.categorySpendingMap.isNotEmpty) ...[
                CategorySummaryPills(
                  categorySpending: expenseProvider.categorySpendingMap,
                  currencySymbol: themeProvider.currencySymbol,
                  onCategoryTap: (category) {
                    expenseProvider.setSelectedCategory(category);
                    onNavigateToList();
                  },
                ),
                const SizedBox(height: 18),
              ],

              // Metric Stats Row
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Daily Average',
                      value: CurrencyFormatter.format(
                        expenseProvider.averageDailyExpenseForMonth,
                        symbol: themeProvider.currencySymbol,
                      ),
                      icon: Icons.calendar_view_day_rounded,
                      iconColor: AppColors.secondary,
                      subtitle: 'Across current month',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Top Category',
                      value: expenseProvider.topCategory?.displayName ?? 'None',
                      icon: expenseProvider.topCategory?.icon ?? Icons.pie_chart_outline_rounded,
                      iconColor: expenseProvider.topCategory?.color ?? AppColors.primary,
                      subtitle: '${selectedMonthExpenses.length} transactions',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category Breakdown Chart Section
              if (selectedMonthExpenses.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category Breakdown',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      '${expenseProvider.categorySpendingMap.length} categories',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                    categoryData: expenseProvider.categorySpendingMap,
                    currencySymbol: themeProvider.currencySymbol,
                  ),
                ),
                const SizedBox(height: 24),

                // 6-Month Spending Trend Bar Chart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '6-Month Spending Trend',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const Icon(Icons.bar_chart_rounded, size: 20, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 24),
              ],

              // Recent Transactions List Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  if (selectedMonthExpenses.isNotEmpty)
                    TextButton(
                      onPressed: onNavigateToList,
                      child: const Text('View All'),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (selectedMonthExpenses.isEmpty)
                EmptyStateView(
                  title: 'No Expenses in this Month',
                  message: 'You have not tracked any expenses for this period yet. Tap below to log one.',
                  actionLabel: 'Add First Expense',
                  onAction: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
                    );
                  },
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentExpenses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final expense = recentExpenses[index];
                    return ExpenseCard(
                      expense: expense,
                      currencySymbol: themeProvider.currencySymbol,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpenseDetailScreen(expense: expense),
                          ),
                        );
                      },
                      onDelete: () async {
                        await expenseProvider.deleteExpense(expense.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Expense deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                textColor: Colors.white,
                                onPressed: () => expenseProvider.undoDelete(),
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
