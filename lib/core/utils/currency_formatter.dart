import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount, {String symbol = 'LKR'}) {
    final displaySymbol = symbol == 'LKR' ? 'LKR ' : symbol;
    final formatter = NumberFormat.currency(
      symbol: displaySymbol,
      decimalDigits: amount.truncateToDouble() == amount ? 2 : 2,
    );
    return formatter.format(amount);
  }

  static String formatCompact(double amount, {String symbol = 'LKR'}) {
    final displaySymbol = symbol == 'LKR' ? 'LKR ' : symbol;
    if (amount >= 1000000) {
      return '$displaySymbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 10000) {
      return '$displaySymbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount, symbol: symbol);
  }
}
