import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/providers.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/expense_category_model.dart';
import '../../data/datasources/local/expense_category_local_datasource.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() =>
      _ExpensesScreenState();
}

class _ExpensesScreenState
    extends ConsumerState<ExpensesScreen> {

  List<Expense> expenses = [];
  List<ExpenseCategory> categories = [];

 int? selectedCategoryId;

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _newCategoryController = TextEditingController();

  final ExpenseCategoryLocalDataSource _categoryDataSource =
      ExpenseCategoryLocalDataSource();

  @override
  void initState() {
    super.initState();
    loadCategories();
    loadExpenses();
  }

  Future<void> loadCategories() async {
    final data = await _categoryDataSource.getCategories();
    setState(() {
      categories = data;
    });
  }

  Future<void> addCategoryDialog() async {
  _newCategoryController.clear();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Add Category"),
      content: TextField(
        controller: _newCategoryController,
        decoration: const InputDecoration(
          labelText: "Category Name",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final name =
                _newCategoryController.text.trim();

            if (name.isNotEmpty) {
              await _categoryDataSource.insertCategory(
                ExpenseCategory(name: name),
              );

              Navigator.pop(context);
              loadCategories();
            }
          },
          child: const Text("Save"),
        )
      ],
    ),
  );
}

  Future<void> loadExpenses() async {
    final repo = ref.read(expenseRepositoryProvider);
    final data = await repo.getAllExpenses();
    setState(() {
      expenses = data;
    });
  }

  Future<void> addExpense() async {
    if (selectedCategoryId == null) return;

    final amount =
        double.tryParse(_amountController.text) ?? 0;

    if (amount <= 0) return;

final expense = Expense(
  date: DateTime.now().toIso8601String(),
  amount: amount,
  categoryId: selectedCategoryId!,
  note: _noteController.text.trim(),
);

    await ref
        .read(expenseRepositoryProvider)
        .addExpense(expense);

    _amountController.clear();
    _noteController.clear();
setState(() {
  selectedCategoryId = null;
});
    loadExpenses();
  }

Future<void> manageCategoryDialog() async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Manage Categories"),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: categories.map((category) {
            return ListTile(
              title: Text(category.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // EDIT
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _newCategoryController.text =
                          category.name;
                      Navigator.pop(context);
                      editCategoryDialog(category);
                    },
                  ),

                  // DELETE
                  IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red),
                    onPressed: () async {
                      final used =
                          await _categoryDataSource
                              .isCategoryUsed(category.id!);

                      if (used) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Cannot delete. Category is used in expenses."),
                          ),
                        );
                        return;
                      }

                      await _categoryDataSource
                          .deleteCategory(category.id!);

                      Navigator.pop(context);
                      loadCategories();
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            addCategoryDialog();
          },
          child: const Text("Add New"),
        )
      ],
    ),
  );
}


Future<void> editCategoryDialog(
    ExpenseCategory category) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Edit Category"),
      content: TextField(
        controller: _newCategoryController,
        decoration: const InputDecoration(
          labelText: "Category Name",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final newName =
                _newCategoryController.text.trim();

            if (newName.isNotEmpty) {
              await _categoryDataSource.updateCategory(
                  category.id!, newName);

              _newCategoryController.clear();
              Navigator.pop(context);
              loadCategories();
            }
          },
          child: const Text("Save"),
        )
      ],
    ),
  );
}

  String getCategoryName(int id) {
    final match =
        categories.firstWhere((c) => c.id == id,
            orElse: () => ExpenseCategory(name: "Unknown"));
    return match.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
  value: selectedCategoryId,
  items: categories.map((category) {
    return DropdownMenuItem<int>(
      value: category.id,
      child: Text(category.name),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      selectedCategoryId = value;
    });
  },
  decoration: const InputDecoration(
    labelText: "Select Category",
  ),
),
                ),
IconButton(
  onPressed: manageCategoryDialog,
  icon: const Icon(Icons.settings),
)
              ],
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Amount",
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: "Note (optional)",
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: addExpense,
              child: const Text("Add Expense"),
            ),

            const Divider(),

Expanded(
  child: ListView.builder(
    itemCount: expenses.length,
    itemBuilder: (context, index) {
      final e = expenses[index];
      final date =
          DateFormat('dd MMM yyyy – hh:mm a')
              .format(DateTime.parse(e.date));

      return Dismissible(
        key: Key(e.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: Colors.red,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        confirmDismiss: (_) async {
          return await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Delete Expense"),
              content: const Text(
                  "Are you sure you want to delete this expense?"),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, true),
                  child: const Text("Delete"),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) async {
          await ref
              .read(expenseRepositoryProvider)
              .deleteExpense(e.id!);

          loadExpenses();

          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
              content: Text("Expense deleted"),
            ),
          );
        },
        child: ListTile(
          title: Text(
            getCategoryName(e.categoryId),
          ),
          subtitle: Text(
            "${e.note ?? ''}\n$date",
          ),
          trailing: Text(
            "₹ ${e.amount}",
            style: const TextStyle(
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    },
  ),
),
          ],
        ),
      ),
    );
  }
}