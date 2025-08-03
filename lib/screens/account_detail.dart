import 'package:flutter/material.dart';
import 'package:money_app/models/account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_app/providers/database.dart';

class AccountDetailScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final String? id;
  final Map<String, dynamic>? account;

  const AccountDetailScreen({
    super.key,
    required this.isEdit,
    this.id,
    this.account,
  });

  @override
  ConsumerState<AccountDetailScreen> createState() =>
      _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  // declare input variables
  final _formKey = GlobalKey<FormState>();
  final List<String> _currencies = ['MYR', 'SGD'];
  String _selectedCurrency = ''; // Variable to hold the selected option
  String _name = '';

  // submit form
  void _submit(context) async {
    if (_formKey.currentState!.validate()) {
      final database = ref.read(databaseProvider);

      Account a = Account(id: '', name: _name, currency: _selectedCurrency);
      if (widget.isEdit) {
        await database.editAccount(a, widget.id!);
      } else {
        await database.addNewAccount(a);
      }
      // go back one page
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      _selectedCurrency = widget.account!['currency'];
      _name = widget.account!['name'];
    } else {
      _selectedCurrency = _currencies.first; // Set initial selected option
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isEdit ? Text('Edit Account') : Text('Add Account'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Account Name'),
                initialValue: widget.isEdit ? widget.account!['name'] : '',
                onChanged: (value) {
                  _name = value;
                },
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
