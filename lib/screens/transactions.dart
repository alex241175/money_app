import 'package:flutter/material.dart';
import 'package:money_app/screens/transaction_detail.dart';
import 'package:money_app/models/transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_app/providers/database.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // For Timer and Debounce

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  Future<dynamic>? _futureData;
  // Store the full list of transactions once fetched from Firestore
  List<Transaction> _allTransactions = [];
  // The list that will be displayed and filtered
  List<Transaction> _filteredTransactions = [];
  // Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  // For debouncing search input
  Timer? _debounce;
  final Duration _debounceDuration = const Duration(
    milliseconds: 300,
  ); // Adjust as needed

  @override
  void initState() {
    super.initState();
    final database = ref.read(databaseProvider);
    setState(() {
      _futureData = database.allTransactions;
    });
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

  void _onSearchChanged() {
    // Cancel the previous timer if it's still active
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start a new timer
    _debounce = Timer(_debounceDuration, () {
      _filterTransactions(_searchController.text);
    });
  }

  void _filterTransactions(String query) {
    // Ensure the widget is still mounted before calling setState
    if (!mounted) return;

    setState(() {
      if (query.isEmpty) {
        // If query is empty, show all transactions
        _filteredTransactions = List.from(_allTransactions);
      } else {
        // Filter transactions based on the query (case-insensitive)
        _filteredTransactions = _allTransactions.where((transaction) {
          final lowerCaseQuery = query.toLowerCase();
          return transaction.note!.toLowerCase().contains(lowerCaseQuery) ||
              transaction.category.toLowerCase().contains(lowerCaseQuery);
          // Add more fields to search as needed
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.read(databaseProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Transactions'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight((60)), //Height of the search bar
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
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
                    setState(() {
                      _futureData = database.allTransactions;
                    });
                  });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No transactions found.'));
          } else {
            // Data has arrived from Firestore
            // Map each DocumentSnapshot to a Transaction object explicitly
            final List<Transaction> fetchedTransactions = snapshot.data!.docs
                .map<Transaction>((doc) => Transaction.fromFirestore(doc, null))
                .toList(); // Convert the iterable to a List<Transaction>
            _allTransactions = fetchedTransactions;
            _filteredTransactions = fetchedTransactions;
          }
          // ListView.builder now uses _filteredTransactions

          return ListView.builder(
            itemCount: _filteredTransactions.length,
            itemBuilder: (ctx, index) {
              final item = _filteredTransactions[index];
              final id = item.id;
              final dateTime = item.dateTime;
              final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
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
                      Text('${item.currency} ${item.amount.toString()}'),
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
                            setState(() {
                              _futureData = database.allTransactions;
                            });
                          });
                    },
                    icon: Icon(Icons.edit),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
