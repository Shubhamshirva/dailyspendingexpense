
import 'package:dailyspendingexpense/bloc/expense/expense_bloc.dart';
import 'package:dailyspendingexpense/bloc/expense/expense_event.dart';
import 'package:dailyspendingexpense/bloc/expense/expense_state.dart';
import 'package:dailyspendingexpense/models/category.dart';
import 'package:dailyspendingexpense/pages/category_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _categoryNameController = TextEditingController();

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  late ExpenseBloc _expenseBloc;

@override
void initState() {
  super.initState();
  _expenseBloc = context.read<ExpenseBloc>(); // store once
}
  

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: _categoryNameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'e.g., Groceries, Entertainment',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _categoryNameController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_categoryNameController.text.isNotEmpty) {
                  context.read<ExpenseBloc>().add(AddCategory(_categoryNameController.text));
                  Navigator.of(context).pop();
                  _categoryNameController.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(Category category) {
    _categoryNameController.text = category.name; // Pre-fill with current name
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: TextField(
            controller: _categoryNameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _categoryNameController.clear();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_categoryNameController.text.isNotEmpty) {
                  context.read<ExpenseBloc>().add(
                    UpdateCategory(category.copyWith(name: _categoryNameController.text)),
                  );
                  Navigator.of(context).pop();
                  _categoryNameController.clear();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int categoryId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Category?'),
          content: const Text('Are you sure you want to delete this category and all its associated expenses?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ExpenseBloc>().add(DeleteCategory(categoryId));
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
        title: const Text('Daily Spending Tracker'),
        centerTitle: true,
      ),
      body: BlocBuilder<ExpenseBloc, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpenseLoaded) {
            final categories = state.categories;
            final allExpenses = state.allExpenses;
            final overallTotal = allExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    color: Colors.blue.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Overall Total Spendings:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${overallTotal.toStringAsFixed(2)}',
                          
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: categories.isEmpty
                      ? const Center(
                          child: Text(
                            'No categories added yet.\nTap the + button to add your first category!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 1.2, // Adjust as needed
                          ),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return GestureDetector(
                              onTap: () async {
                                print("going ot next page");
                               await  
                               Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CategoryDetailPage(category: category,
                                     onReturn: () {
          _expenseBloc.add(LoadCategories()); // Use a reference instead of context.read
        },
                                    ),
                                  ),
                                );
                                // ignore: use_build_context_synchronously

                              },
                              onLongPress: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  builder: (context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        ListTile(
                                          leading: const Icon(Icons.edit),
                                          title: const Text('Edit Category'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _showEditCategoryDialog(category);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.delete, color: Colors.red),
                                          title: const Text('Delete Category', style: TextStyle(color: Colors.red)),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _showDeleteConfirmationDialog(category.id!);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.lightBlue.shade100,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.folder, size: 48, color: Colors.blueAccent.shade700),
                                        const SizedBox(height: 8,),
                                        Text(
                                          category.name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCategoryDialog,
        label: const Text('Add Category'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
