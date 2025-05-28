import 'package:equatable/equatable.dart';
import '../../models/category.dart';
import '../../models/expense.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends ExpenseEvent {}

class AddCategory extends ExpenseEvent {
  final String name;

  const AddCategory(this.name);

  @override
  List<Object> get props => [name];
}

class UpdateCategory extends ExpenseEvent {
  final Category category;

  const UpdateCategory(this.category);

  @override
  List<Object> get props => [category];
}

class DeleteCategory extends ExpenseEvent {
  final int categoryId;

  const DeleteCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class AddExpense extends ExpenseEvent {
  final Expense expense;

  const AddExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

class LoadExpensesForCategory extends ExpenseEvent {
  final int categoryId;

  const LoadExpensesForCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class UpdateExpense extends ExpenseEvent {
  final Expense expense;

  const UpdateExpense(this.expense);

  @override
  List<Object> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final int expenseId;
  final int categoryId; // To reload expenses for the category

  const DeleteExpense(this.expenseId, this.categoryId);

  @override
  List<Object> get props => [expenseId, categoryId];
}