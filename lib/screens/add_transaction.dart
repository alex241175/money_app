import 'package:flutter/material.dart';
import 'package:money_app/models/transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_app/providers/transactions.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final String? id;
  final Map<String, dynamic>? transaction;

  const AddTransactionScreen({
    super.key,
    required this.isEdit,
    this.id,
    this.transaction,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  // declare input variables
  final _formKey = GlobalKey<FormState>();
  final List<String> _categories = ['Food', 'Transport', 'Car', 'Utility'];
  final List<String> _accounts = ['Cash', 'CIMB Bank', 'TNG'];
  final List<String> _currencies = ['MYR', 'SGD'];
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedAccount = ''; // Variable to hold the selected option
  String _selectedCategory = ''; // Variable to hold the selected option
  String _selectedCurrency = ''; // Variable to hold the selected option
  double _amount = 0;
  String _note = '';

  // submit form
  void _submit(context) async {
    if (_formKey.currentState!.validate()) {
      final database = ref.read(databaseProvider);

      Transaction t = Transaction(
        dateTime: _selectedDate!,
        category: _selectedCategory,
        account: _selectedAccount,
        currency: _selectedCurrency,
        amount: _amount,
        note: _note,
      );
      if (widget.isEdit) {
        await database.editTransaction(t, widget.id!);
      } else {
        await database.addNewTransaction(t);
      }
      // go back one page
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      _selectedDate = widget.transaction!['dateTime'].toDate();
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      _selectedCategory = widget.transaction!['category'];
      _selectedAccount = widget.transaction!['account'];
      _selectedCurrency = widget.transaction!['currency'];
      _amount = widget.transaction!['amount'];
      _note = widget.transaction!['note'];
    } else {
      _selectedDate = DateTime.now();
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _selectedCategory = _categories.first; // Set initial selected option
      _selectedAccount = _accounts.first; // Set initial selected option
      _selectedCurrency = _currencies.first; // Set initial selected option
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isEdit
            ? Text('Edit Transaction')
            : Text('Add Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _dateController,
                readOnly: true, // Prevents manual input
                decoration: InputDecoration(
                  labelText: 'Select Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  // Call the date picker when the field is tapped
                  _selectedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000), // Earliest selectable date
                    lastDate: DateTime(2100), // Latest selectable date
                  );

                  if (_selectedDate != null) {
                    // Format the picked date and update the text field
                    String formattedDate = DateFormat(
                      'yyyy-MM-dd',
                    ).format(_selectedDate!);
                    _dateController.text = formattedDate;
                  }
                },
              ),

              DropdownButton<String>(
                value: _selectedAccount,
                items: _accounts.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAccount = newValue!;
                  });
                },
                hint: Text('Select an account'), // Optional hint text
              ),
              DropdownButton<String>(
                value: _selectedCategory,
                items: _categories.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                hint: Text('Select a category'), // Optional hint text
              ),
              DropdownButton<String>(
                value: _selectedCurrency,
                items: _currencies.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCurrency = newValue!;
                  });
                },
                hint: Text('Select a currency'), // Optional hint text
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                initialValue: widget.isEdit
                    ? widget.transaction!['amount'].toString()
                    : '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  return null;
                },
                onChanged: (value) {
                  _amount = double.parse(value);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Note'),
                initialValue: widget.isEdit ? widget.transaction!['note'] : '',
                onChanged: (value) {
                  _note = value;
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
