import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final int? id;
  final int categoryId;
  final String name;
  final double amount;
  final DateTime date;

  const Expense({
    this.id,
    required this.categoryId,
    required this.name,
    required this.amount,
    required this.date,
  });

  // Convert an Expense object into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(), // Store date as ISO 8601 string
    };
  }

  // Extract an Expense object from a Map.
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      categoryId: map['categoryId'],
      name: map['name'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }

  @override
  List<Object?> get props => [id, categoryId, name, amount, date];

  // Method to create a copy of the Expense with updated fields
  Expense copyWith({
    int? id,
    int? categoryId,
    String? name,
    double? amount,
    DateTime? date,
  }) {
    return Expense(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}