import '../../data/models/expense_model.dart';
import 'date_formatter.dart';

class CsvExporter {
  CsvExporter._();

  static String generateCsv(List<ExpenseModel> expenses) {
    final buffer = StringBuffer();
    // Header
    buffer.writeln('ID,Title,Amount,Category,Date,Note');

    for (final exp in expenses) {
      final safeTitle = _escapeCsv(exp.title);
      final safeNote = _escapeCsv(exp.note ?? '');
      final formattedDate = DateFormatter.format(exp.date);
      buffer.writeln('${exp.id},$safeTitle,${exp.amount.toStringAsFixed(2)},${exp.category.displayName},$formattedDate,$safeNote');
    }

    return buffer.toString();
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
