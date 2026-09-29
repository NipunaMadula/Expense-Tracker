import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/expense_category.dart';
import '../../../../providers/expense_provider.dart';

class ExpenseFilterSheet extends StatefulWidget {
  const ExpenseFilterSheet({
    super.key,
    required this.selectedCategory,
    required this.selectedDateRange,
    required this.sortOption,
    required this.onApply,
    required this.onReset,
  });

  final ExpenseCategory? selectedCategory;
  final DateTimeRange? selectedDateRange;
  final ExpenseSortOption sortOption;
  final void Function(
    ExpenseCategory? category,
    DateTimeRange? dateRange,
    ExpenseSortOption sortOption,
  ) onApply;
  final VoidCallback onReset;

  @override
  State<ExpenseFilterSheet> createState() => _ExpenseFilterSheetState();
}

class _ExpenseFilterSheetState extends State<ExpenseFilterSheet> {
  late ExpenseCategory? _category;
  late DateTimeRange? _dateRange;
  late ExpenseSortOption _sort;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _dateRange = widget.selectedDateRange;
    _sort = widget.sortOption;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter & Sort',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _category = null;
                      _dateRange = null;
                      _sort = ExpenseSortOption.dateDesc;
                    });
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Date Range Picker
            Text(
              'Date Range',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDateRange,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range_rounded, size: 20, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _dateRange == null
                            ? 'All dates in selected month (Tap to customize range)'
                            : '${DateFormatter.format(_dateRange!.start)} - ${DateFormatter.format(_dateRange!.end)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _dateRange != null ? FontWeight.w600 : FontWeight.w400,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    if (_dateRange != null)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => setState(() => _dateRange = null),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Category Filter
            Text(
              'Filter by Category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('All Categories'),
                  selected: _category == null,
                  onSelected: (val) {
                    if (val) setState(() => _category = null);
                  },
                ),
                ...ExpenseCategory.values.map((cat) {
                  final isSelected = _category == cat;
                  return FilterChip(
                    avatar: Icon(cat.icon, size: 16, color: isSelected ? Colors.white : cat.color),
                    label: Text(cat.displayName),
                    selected: isSelected,
                    selectedColor: cat.color,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      setState(() {
                        _category = val ? cat : null;
                      });
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),
            // Sort by
            Text(
              'Sort By',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ExpenseSortOption.values.map((option) {
                final isSelected = _sort == option;
                return ChoiceChip(
                  label: Text(option.label),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _sort = option);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Apply Button
            ElevatedButton(
              onPressed: () {
                widget.onApply(_category, _dateRange, _sort);
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
