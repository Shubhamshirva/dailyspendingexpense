
import 'package:dailyspendingexpense/bloc/expense/expense_bloc.dart';
import 'package:dailyspendingexpense/bloc/expense/expense_event.dart';
import 'package:dailyspendingexpense/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddExpenseDialog extends StatefulWidget {
  final int categoryId;
  final Expense? expenseToEdit; // Optional: if editing an existing expense

  const AddExpenseDialog({
    Key? key,
    required this.categoryId,
    this.expenseToEdit,
  }) : super(key: key);

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      _nameController.text = widget.expenseToEdit!.name;
      _amountController.text = widget.expenseToEdit!.amount.toString();
      _selectedDate = widget.expenseToEdit!.date;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitExpense() {
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final double amount = double.parse(_amountController.text);

      if (widget.expenseToEdit == null) {
        // Add new expense
        final newExpense = Expense(
          categoryId: widget.categoryId,
          name: name,
          amount: amount,
          date: _selectedDate,
        );
        context.read<ExpenseBloc>().add(AddExpense(newExpense));
      } else {
        // Update existing expense
        final updatedExpense = widget.expenseToEdit!.copyWith(
          name: name,
          amount: amount,
          date: _selectedDate,
        );
        context.read<ExpenseBloc>().add(UpdateExpense(updatedExpense));
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.expenseToEdit == null ? 'Add New Expense' : 'Edit Expense'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Expense Name',
                  hintText: 'e.g., Coffee, Movie Ticket',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an expense name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  hintText: 'e.g., 50.00',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitExpense,
          child: Text(widget.expenseToEdit == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}