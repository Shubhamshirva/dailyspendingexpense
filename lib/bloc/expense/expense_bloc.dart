import 'package:flutter_bloc/flutter_bloc.dart';
import '../../db/database_helper.dart';
import '../../models/category.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final DatabaseHelper _databaseHelper;

  ExpenseBloc(this._databaseHelper) : super(ExpenseInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<AddExpense>(_onAddExpense);
    on<LoadExpensesForCategory>(_onLoadExpensesForCategory);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
  }

  Future<void> _onLoadCategories(LoadCategories event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      final categories = await _databaseHelper.getCategories();
      final allExpenses = await _databaseHelper.getAllExpenses();
      emit(ExpenseLoaded(categories: categories, allExpenses: allExpenses));
    } catch (e) {
      emit(ExpenseError('Failed to load categories and expenses: $e'));
    }
  }

  Future<void> _onAddCategory(AddCategory event, Emitter<ExpenseState> emit) async {
    try {
      await _databaseHelper.insertCategory(Category(name: event.name));
      // Reload all categories and expenses after adding
      add(LoadCategories());
    } catch (e) {
      emit(ExpenseError('Failed to add category: $e'));
    }
  }

  Future<void> _onUpdateCategory(UpdateCategory event, Emitter<ExpenseState> emit) async {
    try {
      await _databaseHelper.updateCategory(event.category);
      add(LoadCategories()); // Reload categories after update
    } catch (e) {
      emit(ExpenseError('Failed to update category: $e'));
    }
  }

  Future<void> _onDeleteCategory(DeleteCategory event, Emitter<ExpenseState> emit) async {
    try {
      await _databaseHelper.deleteCategory(event.categoryId);
      add(LoadCategories()); // Reload categories after deletion
    } catch (e) {
      emit(ExpenseError('Failed to delete category: $e'));
    }
  }

  Future<void> _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    try {
      await _databaseHelper.insertExpense(event.expense);
      // If currently on a category detail page, reload expenses for that category
      if (state is CategoryExpensesLoaded) {
        final currentCategory = (state as CategoryExpensesLoaded).category;
        add(LoadExpensesForCategory(currentCategory.id!));
      } else {
        // Otherwise, reload all expenses for the home page
        add(LoadCategories());
      }
    } catch (e) {
      emit(ExpenseError('Failed to add expense: $e'));
    }
  }

  Future<void> _onLoadExpensesForCategory(LoadExpensesForCategory event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading()); // Emit loading state
    try {
      final expenses = await _databaseHelper.getExpensesByCategoryId(event.categoryId);
      final categories = await _databaseHelper.getCategories();
      final currentCategory = categories.firstWhere((cat) => cat.id == event.categoryId);
      emit(CategoryExpensesLoaded(expenses: expenses, category: currentCategory));
    } catch (e) {
      emit(ExpenseError('Failed to load expenses for category: $e'));
    }
  }

  Future<void> _onUpdateExpense(UpdateExpense event, Emitter<ExpenseState> emit) async {
    try {
      await _databaseHelper.updateExpense(event.expense);
      // Reload expenses for the specific category after update
      add(LoadExpensesForCategory(event.expense.categoryId));
    } catch (e) {
      emit(ExpenseError('Failed to update expense: $e'));
    }
  }

  Future<void> _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    try {
      await _databaseHelper.deleteExpense(event.expenseId);
      // Reload expenses for the specific category after deletion
      add(LoadExpensesForCategory(event.categoryId));
    } catch (e) {
      emit(ExpenseError('Failed to delete expense: $e'));
    }
  }
}