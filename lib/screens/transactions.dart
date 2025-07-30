import 'package:flutter/material.dart';
import 'package:money_app/screens/add_transaction.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_app/providers/transactions.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.read(databaseProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AddTransactionScreen(isEdit: false),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: database.allTransactions,
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.error != null) {
            return Center(child: Text('Some error occurred'));
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, index) {
              final item = items[index].data();
              final id = items[index].id;
              final dateTime = item['dateTime'].toDate();
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
                key: Key(id),
                direction: DismissDirection.endToStart,
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$formattedDate [${item['account']}]'),
                      Text('${item['currency']} ${item['amount'].toString()}'),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(item['category']), Text(item['note'])],
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => AddTransactionScreen(
                            isEdit: true,
                            id: id,
                            transaction: item,
                          ),
                        ),
                      );
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
