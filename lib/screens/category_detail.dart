import 'package:flutter/material.dart';
import 'package:money_app/models/category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_app/providers/database.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final String? id;
  final Map<String, dynamic>? category;

  const CategoryDetailScreen({
    super.key,
    required this.isEdit,
    this.id,
    this.category,
  });

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  // declare input variables
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';

  // submit form
  void _submit(context) async {
    if (_formKey.currentState!.validate()) {
      final database = ref.read(databaseProvider);

      Category a = Category(id: '', name: _name, description: _description);
      if (widget.isEdit) {
        await database.editCategory(a, widget.id!);
      } else {
        await database.addNewCategory(a);
      }
      // go back one page
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      _name = widget.category!['name'];
      _description = widget.category!['description'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isEdit ? Text('Edit Category') : Text('Add Category'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category Name'),
                initialValue: widget.isEdit ? widget.category!['name'] : '',
                onChanged: (value) {
                  _name = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                initialValue: widget.isEdit
                    ? widget.category!['description']
                    : '',
                onChanged: (value) {
                  _description = value;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _submit(context),
                child: widget.isEdit ? Text('Update') : Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
