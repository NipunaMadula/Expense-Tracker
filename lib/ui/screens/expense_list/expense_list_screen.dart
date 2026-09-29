import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_model.dart';
import '../../../providers/expense_provider.dart';
import '../../../providers/theme_provider.dart';
import '../dashboard/widgets/month_selector.dart';
import '../expense_detail/expense_detail_screen.dart';
import '../expense_form/expense_form_screen.dart';
import 'widgets/expense_card.dart';
import 'widgets/expense_filter_sheet.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet(BuildContext context, ExpenseProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseFilterSheet(
        selectedCategory: provider.selectedCategory,
        selectedDateRange: provider.selectedDateRange,
        sortOption: provider.sortOption,
        onApply: (category, dateRange, sort) {
          provider.setSelectedCategory(category);
          provider.setDateRange(dateRange);
          provider.setSortOption(sort);
        },
        onReset: () {
          provider.clearAllFilters();
        },
      ),
    );
  }

  void _showExpenseActionSheet(
    BuildContext context,
    ExpenseModel expense,
    ExpenseProvider provider,
    ThemeProvider theme,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: expense.category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(expense.category.icon, color: expense.category.color, size: 22),
                ),
                title: Text(
                  expense.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  '${expense.category.displayName} • ${CurrencyFormatter.format(expense.amount, symbol: theme.currencySymbol)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                title: const Text('Edit Expense'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExpenseFormScreen(expenseToEdit: expense),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: AppColors.secondary),
                title: const Text('Duplicate for Today'),
                subtitle: const Text('Quickly log the same expense for today', style: TextStyle(fontSize: 11)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final duplicate = expense.copyWith(
                    id: const Uuid().v4(),
                    date: DateTime.now(),
                    createdAt: DateTime.now(),
                  );
                  final success = await provider.addExpense(duplicate);
                  if (context.mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Duplicated "${expense.title}" for today!'),
                        backgroundColor: AppColors.success,
                        action: SnackBarAction(
                          label: 'Undo',
                          textColor: Colors.white,
                          onPressed: () => provider.deleteExpense(duplicate.id),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded, color: AppColors.info),
                title: const Text('View Full Details'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExpenseDetailScreen(expense: expense),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                title: const Text('Delete Expense', style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Delete Expense?'),
                      content: Text('Are you sure you want to delete "${expense.title}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                          onPressed: () => Navigator.pop(dCtx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await provider.deleteExpense(expense.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Expense deleted'),
                          action: SnackBarAction(
                            label: 'Undo',
                            textColor: Colors.white,
                            onPressed: () => provider.undoDelete(),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormatter.formatWithDay(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    if (expenseProvider.isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Loading your expense records...'),
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

    final filteredList = expenseProvider.filteredExpenses;
    final totalFilteredAmount = filteredList.fold(0.0, (sum, e) => sum + e.amount);

    final hasActiveFilter = expenseProvider.selectedCategory != null ||
        expenseProvider.selectedDateRange != null ||
        expenseProvider.periodFilter != ExpensePeriodFilter.thisMonth ||
        expenseProvider.searchQuery.isNotEmpty;

    // Group expenses by date (sorted in order of list)
    final groupedMap = <DateTime, List<ExpenseModel>>{};
    for (final exp in filteredList) {
      final dateOnly = DateTime(exp.date.year, exp.date.month, exp.date.day);
      groupedMap.putIfAbsent(dateOnly, () => []).add(exp);
    }
    final dateGroups = groupedMap.entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense History'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: hasActiveFilter,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.filter_list_rounded),
            ),
            tooltip: 'Filter & Sort',
            onPressed: () => _openFilterSheet(context, expenseProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => expenseProvider.refresh(),
        child: Column(
          children: [
            // Period Filter Bar (This Month / Last Month / 3 Months / This Year / All)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: ExpensePeriodFilter.values.map((period) {
                  final isSelected = expenseProvider.periodFilter == period &&
                      expenseProvider.selectedDateRange == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(period.label),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      onSelected: (val) {
                        if (val) {
                          expenseProvider.setPeriodFilter(period);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // Month Selector (Visible when 'This Month' period is selected)
            if (expenseProvider.periodFilter == ExpensePeriodFilter.thisMonth &&
                expenseProvider.selectedDateRange == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: MonthSelector(
                  selectedMonth: expenseProvider.selectedMonth,
                  onPrevious: () => expenseProvider.previousMonth(),
                  onNext: () => expenseProvider.nextMonth(),
                  onReset: () => expenseProvider.resetToCurrentMonth(),
                ),
              ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => expenseProvider.setSearchQuery(val),
                decoration: InputDecoration(
                  hintText: 'Search by title, note, or amount...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            expenseProvider.setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Quick Category Filter Bar
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All Categories'),
                      selected: expenseProvider.selectedCategory == null,
                      onSelected: (_) => expenseProvider.setSelectedCategory(null),
                    ),
                  ),
                  ...ExpenseCategory.values.map((cat) {
                    final isSelected = expenseProvider.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        avatar: Icon(
                          cat.icon,
                          size: 14,
                          color: isSelected ? Colors.white : cat.color,
                        ),
                        label: Text(cat.displayName),
                        selected: isSelected,
                        selectedColor: cat.color,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) {
                          expenseProvider.setSelectedCategory(val ? cat : null);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Summary Info Strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredList.length} ${filteredList.length == 1 ? 'expense' : 'expenses'}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Total: ',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(totalFilteredAmount, symbol: themeProvider.currencySymbol),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Main Expense List View (Grouped by Date)
            Expanded(
              child: filteredList.isEmpty
                  ? EmptyStateView(
                      icon: Icons.search_off_rounded,
                      title: 'No Matching Expenses Found',
                      message: hasActiveFilter
                          ? 'Try adjusting your search query, selected category, or period filter.'
                          : 'No expenses have been recorded for this period yet.',
                      actionLabel: hasActiveFilter ? 'Clear Filters' : 'Add Expense',
                      onAction: () {
                        if (hasActiveFilter) {
                          _searchController.clear();
                          expenseProvider.clearAllFilters();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
                          );
                        }
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: dateGroups.length,
                      itemBuilder: (context, groupIndex) {
                        final group = dateGroups[groupIndex];
                        final date = group.key;
                        final dayExpenses = group.value;
                        final dayTotal = dayExpenses.fold(0.0, (sum, e) => sum + e.amount);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Section Header with Day Total
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 13,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatDateHeader(date),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.surfaceVariantDark
                                          : AppColors.surfaceVariantLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      CurrencyFormatter.format(dayTotal, symbol: themeProvider.currencySymbol),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Expense Cards for this day
                            ...dayExpenses.map((expense) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ExpenseCard(
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
                                  onLongPress: () {
                                    _showExpenseActionSheet(
                                      context,
                                      expense,
                                      expenseProvider,
                                      themeProvider,
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
                                ),
                              );
                            }),
                            const SizedBox(height: 6),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExpenseFormScreen()),
          );
        },
        tooltip: 'Add Expense',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
