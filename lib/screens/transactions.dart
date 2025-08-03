import 'package:flutter/material.dart';
import 'package:money_app/screens/transaction_detail.dart';
import 'package:money_app/models/transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_app/providers/database.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:money_app/widgets/accounts_drawer.dart'; // For Timer and Debounce

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  // Store the full list of transactions once fetched from Firestore
  List<Transaction> _allTransactions = [];
  // The list that will be displayed and filtered
  List<Transaction> _filteredTransactions = [];
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();
  String _selectedAccount = '';
  bool _isLoading = true;

  // For debouncing search input
  Timer? _debounce;
  final Duration _debounceDuration = const Duration(
    milliseconds: 300,
  ); // Adjust as needed

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    // Listen to changes in the search text field
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel(); // Cancel any active debounce timer
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    try {
      final database = ref.read(databaseProvider);
      final docs = await database.allTransactions;
      final List<Transaction> fetchedTransactions = docs.map<Transaction>((
        doc,
      ) {
        return Transaction(
          id: doc['id'], // The document ID is separate from the data map
          category: doc['category'] ?? '',
          account: doc['account'] ?? '',
          currency: doc['currency'] ?? '',
          amount: doc['amount'].toDouble() ?? 0.0,
          dateTime: doc['dateTime'].toDate() ?? DateTime.now(),
          note: doc['note'] ?? '',
        );
      }).toList(); // Convert the iterable to a List<Transaction>

      if (!mounted) return;

      setState(() {
        _allTransactions = fetchedTransactions;
        _filteredTransactions = fetchedTransactions;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      // Handle error
    }
  }

  void _onSearchChanged() {
    // Cancel the previous timer if it's still active
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start a new timer
    _debounce = Timer(_debounceDuration, () {
      _filterTransactions();
    });
  }

  void _filterAccount(String account) {
    // set filter parameter
    _selectedAccount = account;
    _searchController.clear();
    // run filter
    _filterTransactions();
  }

  void _clearFilterAccount() {
    _selectedAccount = '';
    _searchController.clear();
    _filterTransactions();
  }

  void _filterTransactions() {
    // Ensure the widget is still mounted before calling setState

    // final selectedAccount = ref.watch(
    //   selectedAccountProvider,
    // ); // read the state

    if (!mounted) return;
    Iterable<Transaction> result = _allTransactions;

    if (_selectedAccount.isNotEmpty) {
      result = result.where((t) => t.account == _selectedAccount);
    }

    final query = _searchController.text;
    if (query.isNotEmpty) {
      final lowerCaseQuery = query.toLowerCase();
      result = result.where(
        (t) => t.note!.toLowerCase().contains(lowerCaseQuery),
      );
    }

    setState(() {
      _filteredTransactions = result.toList();
    });
  }
  // setState(() {
  //   if (query.isEmpty) {
  //     // If query is empty, show all transactions
  //     _filteredTransactions = List.from(_allTransactions);
  //   } else {
  //     // Filter transactions based on the query (case-insensitive)
  //     _filteredTransactions = _allTransactions.where((transaction) {
  //       final lowerCaseQuery = query.toLowerCase();
  //       return transaction.note!.toLowerCase().contains(
  //         lowerCaseQuery,
  //       ); //||transaction.category.toLowerCase().contains(lowerCaseQuery);
  //       // Add more fields to search as needed
  //     }).toList();
  //   }
  // });

  @override
  Widget build(BuildContext context) {
    final database = ref.read(databaseProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Transactions'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            _selectedAccount.isEmpty ? 60 : 100,
          ), //Height of the search bar
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              // _onSearchChanged will be called automatically due to listener
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    // _onSearchChanged is already listening, so this is optional
                    // unless you need other immediate actions
                  },
                ),
              ),
              if (_selectedAccount.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  alignment: Alignment.centerLeft,
                  child: InputChip(
                    label: Text(_selectedAccount),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.orange[300],
                    // onPressed: () => print("input chip pressed"),
                    onDeleted: () => _clearFilterAccount(),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (ctx) =>
                          const TransactionDetailScreen(isEdit: false),
                    ),
                  )
                  .then((value) {
                    // this code runs when secondscreen is popped
                    _loadTransactions();
                  });
            },
          ),
        ],
      ),
      drawer: AccountsDrawer(onSelectedAccount: _filterAccount),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _filteredTransactions.isEmpty
          ? Center(child: Text('No transactions found'))
          : ListView.builder(
              itemCount: _filteredTransactions.length,
              itemBuilder: (ctx, index) {
                final item = _filteredTransactions[index];
                final id = item.id;
                final dateTime = item.dateTime;
                final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
                final formattedAmount = NumberFormat(
                  '#,##0',
                  'en_US',
                ).format(item.amount);
                return Dismissible(
                  onDismissed: (direction) async {
                    await database.removeTransaction(id);
                    // Create a SnackBar
                    final snackBar = SnackBar(
                      content: const Text('Deleted!'),
                      duration: const Duration(
                        seconds: 2,
                      ), // Optional: how long it stays visible
                    );

                    // Show the SnackBar
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  key: Key(id!),
                  direction: DismissDirection.endToStart,
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$formattedDate [${item.account}]'),
                        Text('${item.currency} $formattedAmount'),
                      ],
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(item.category), Text(item.note ?? '')],
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (ctx) => TransactionDetailScreen(
                                  isEdit: true,
                                  id: id,
                                  transaction: item,
                                ),
                              ),
                            )
                            .then((value) {
                              // this code runs when secondscreen is popped
                              _loadTransactions();
                            });
                      },
                      icon: Icon(Icons.edit),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
