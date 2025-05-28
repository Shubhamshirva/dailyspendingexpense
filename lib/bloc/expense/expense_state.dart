import 'package:equatable/equatable.dart';
import '../../models/category.dart';
import '../../models/expense.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<Category> categories;
  final List<Expense> allExpenses; // All expenses for overall total

  const ExpenseLoaded({this.categories = const [], this.allExpenses = const []});

  @override
  List<Object> get props => [categories, allExpenses];
}

class CategoryExpensesLoaded extends ExpenseState {
  final List<Expense> expenses;
  final Category category;

  const CategoryExpensesLoaded({required this.expenses, required this.category});

  @override
  List<Object> get props => [expenses, category];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object> get props => [message];
}
