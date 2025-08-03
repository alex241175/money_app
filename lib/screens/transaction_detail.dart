import 'package:flutter/material.dart';
import 'package:money_app/models/account.dart';
import 'package:money_app/models/transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_app/providers/database.dart';
import 'package:intl/intl.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final String? id;
  final Transaction? transaction;

  const TransactionDetailScreen({
    super.key,
    required this.isEdit,
    this.id,
    this.transaction,
  });

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  // declare input variables
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  Account? _selectedAccount; // Variable to hold the selected account object
  String? _selectedCategory; // Variable to hold the selected category value
  double _amount = 0;
  String _note = '';
  bool _isTransfer = false;

  // submit form
  void _submit(context) async {
    if (_formKey.currentState!.validate()) {
      final database = ref.read(databaseProvider);
      Transaction t = Transaction(
        dateTime: _selectedDate!,
        category: _selectedCategory ?? '',
        account: _selectedAccount!.name,
        currency: _selectedAccount!.currency,
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
      _selectedDate = widget.transaction!.dateTime;
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      _selectedCategory = widget.transaction!.category;
      _selectedAccount = Account(
        name: widget.transaction!.account,
        currency: widget.transaction!.currency,
      );
      //_selectedCurrency = widget.transaction!['currency'];
      _amount = widget.transaction!.amount;
      _note = widget.transaction!.note ?? '';
    } else {
      _selectedDate = DateTime.now();
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.read(databaseProvider);
    return Scaffold(
      appBar: AppBar(
        title: widget.isEdit
            ? Text('Edit Transaction')
            : Text('Add Transaction'),

        actions: [
          Text('Transfer Mode'),
          Switch(
            value: _isTransfer,
            onChanged: (value) {
              setState(() {
                _isTransfer = value;
              });
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //Date Field
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
              // //Accounts field
              FutureBuilder<List<Map<String, dynamic>>>(
                future: database.allAccounts,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading data'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data available'));
                  }
                  final items = snapshot.data!;

                  List<DropdownMenuItem<Account>> accounts = [];
                  for (var item in items) {
                    accounts.add(
                      DropdownMenuItem<Account>(
                        value: Account(
                          name: item['name'],
                          currency: item['currency'],
                        ),
                        child: Text(item['name']),
                      ),
                    );
                  }
                  // _selectedAccount = accounts[0].value!;

                  return DropdownButton<Account>(
                    value: _selectedAccount,
                    items: accounts,
                    onChanged: (value) {
                      setState(() {
                        _selectedAccount = value!;
                      });
                    },
                    hint: Text('Select an account'), // Optional hint text
                  );
                },
              ),
              // // Category field
              FutureBuilder(
                future: database.allCategories,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading data'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data available'));
                  }
                  final docs = snapshot.data!;

                  List<DropdownMenuItem<String>> categories = [];
                  for (var doc in docs) {
                    categories.add(
                      DropdownMenuItem<String>(
                        value: doc['name'],
                        child: Text(doc['name']),
                      ),
                    );
                  }
                  // _selectedAccount = accounts[0].value!;

                  return DropdownButton<String>(
                    value: _selectedCategory,
                    items: categories,
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                    hint: Text('Select a category'), // Optional hint text
                  );
                },
              ),
              // currency and amount field
              Row(
                children: [
                  Container(
                    width: 100, // fixed width
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _selectedAccount != null
                          ? _selectedAccount!.currency
                          : '',
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      initialValue: widget.isEdit
                          ? widget.transaction!.amount.toString()
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
                  ),
                ],
              ),

              // Note field
              TextFormField(
                decoration: const InputDecoration(labelText: 'Note'),
                initialValue: widget.isEdit ? widget.transaction!.note : '',
                onChanged: (value) {
                  _note = value;
                },
              ),
              // submit button
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
