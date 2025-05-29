import 'dart:io';
import 'package:dailyspendingexpense/models/expense.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExcelExporter {
  Future<String> exportExpensesToExcel(List<Expense> expenses) async {
  final excel = Excel.createExcel();
  final sheet = excel['Expenses'];
  double grandTotal = 0.0;

  // Header row
  sheet.appendRow([
     TextCellValue('Date'),
     TextCellValue('Category'),
     TextCellValue('Expense Name'),
     TextCellValue('Amount'),
  ]);

  // Group expenses by date
  final Map<String, List<Expense>> grouped = {};
  for (var exp in expenses) {
    final dateStr = exp.date.toIso8601String().substring(0, 10);
    grouped.putIfAbsent(dateStr, () => []).add(exp);
  }

  // Fill rows
  grouped.forEach((date, items) {
    double dailyTotal = 0.0;
    for (var exp in items) {
      sheet.appendRow([
        TextCellValue(date),
        TextCellValue(exp.categoryName ?? ''),
        TextCellValue(exp.name),
        DoubleCellValue(exp.amount),
      ]);
      dailyTotal += exp.amount;
    }

    // Daily total
    sheet.appendRow([
       TextCellValue(''),
       TextCellValue(''),
       TextCellValue('Daily Total:'),
      DoubleCellValue(dailyTotal),
    ]);

    // Spacer
    sheet.appendRow([ TextCellValue('')]);

    grandTotal += dailyTotal;
  });

  // Grand total
  sheet.appendRow([
     TextCellValue(''),
     TextCellValue(''),
     TextCellValue('Grand Total:'),
    DoubleCellValue(grandTotal),
  ]);

  // Save the file
    final customDirectory = Directory('/storage/emulated/0/Download/DailyExpense');

    if (!(await customDirectory.exists())) {
      await customDirectory.create(recursive: true);
    }

    final filePath = '${customDirectory.path}/daily_expenses.xlsx';
  final file = File(filePath);
  
  // final file = File('${directory!.path}/daily_expenses.xlsx');
  // final filePath = '${directory!.path}/daily_expenses.xlsx';

  // final fileBytes = excel.encode();
  // final file = File(filePath);
  // await file.writeAsBytes(fileBytes!, flush: true);

  // return filePath;
    await file.writeAsBytes(excel.encode()!);
    return file.path;
}
}