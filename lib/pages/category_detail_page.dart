
import 'package:dailyspendingexpense/bloc/expense/expense_bloc.dart';
import 'package:dailyspendingexpense/bloc/expense/expense_event.dart';
import 'package:dailyspendingexpense/bloc/expense/expense_state.dart';
import 'package:dailyspendingexpense/models/category.dart';
import 'package:dailyspendingexpense/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/add_expense_dialog.dart';
import 'package:intl/intl.dart'; // For date formatting

class CategoryDetailPage extends StatefulWidget {
  final Category category;
   final VoidCallback? onReturn;


   CategoryDetailPage({Key? key,
    required this.category, 
    this.onReturn
    }) : super(key: key);

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  @override
  void initState() {
    super.initState();
    // Load expenses for this specific category when the page initializes
    context.read<ExpenseBloc>().add(LoadExpensesForCategory(widget.category.id!));
  }

  void _showAddEditExpenseDialog({Expense? expenseToEdit}) {
    showDialog(
      context: context,
      builder: (context) {
        return AddExpenseDialog(
          categoryId: widget.category.id!,
          expenseToEdit: expenseToEdit,
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int expenseId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense?'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ExpenseBloc>().add(DeleteExpense(expenseId, widget.category.id!));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.name} Expenses'),
        leading:  InkWell(
          onTap: () {
            Navigator.pop(context);
    widget.onReturn?.call();
          },
          child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: 25,
                ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CategoryExpensesLoaded) {
            final expenses = state.expenses;
            final categoryTotal = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    color: Colors.green.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Category Total:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${categoryTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: expenses.isEmpty
                      ? const Center(
                          child: Text(
                            'No expenses added for this category yet.\nTap the + button to add one!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                                  child: Icon(Icons.money, color: Colors.blueAccent.shade700),
                                ),
                                title: Text(
                                  expense.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Text(
                                  'Date: ${DateFormat.yMMMd().format(expense.date)}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                trailing: Text(
                                  '₹${expense.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.green,
                                  ),
                                ),
                                onTap: () => _showAddEditExpenseDialog(expenseToEdit: expense),
                                onLongPress: () => _showDeleteConfirmationDialog(expense.id!),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          } else if (state is ExpenseError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddEditExpenseDialog(),
          label: const Text('Add Expense'),
          icon: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}