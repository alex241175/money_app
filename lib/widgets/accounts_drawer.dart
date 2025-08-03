import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_app/providers/database.dart';
import 'package:intl/intl.dart';

class AccountsDrawer extends ConsumerWidget {
  final Function(String) onSelectedAccount;

  const AccountsDrawer({super.key, required this.onSelectedAccount});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.read(databaseProvider);
    return SizedBox(
      width: 400,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Important: Removes default padding
          children: <Widget>[
            SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.orange[100]),
                child: Text(
                  'Accounts',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ),
            FutureBuilder(
              future: database.allTransactions,
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
                final transactions = snapshot.data!;

                // group transaction by acounts and currency and sum up amount
                final Map<String, num> grouped = {};

                for (var tx in transactions) {
                  final account = tx['account'];
                  final currency = tx['currency'];
                  final amount = tx['amount'] ?? 0;
                  final key = '$account [$currency]';
                  grouped[key] = (grouped[key] ?? 0) + amount;
                }

                var items = grouped.entries.toList(); // convert map to list
                items.sort((a, b) => a.key.compareTo(b.key)); // sort by key

                return Column(
                  children: items.map((entry) {
                    final formattedAmount = NumberFormat(
                      '#,##0',
                      'en_US',
                    ).format(entry.value);
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(entry.key), Text(formattedAmount)],
                      ),
                      onTap: () {
                        final account = entry.key.split(' [')[0];
                        onSelectedAccount(account);
                        // ref.read(selectedAccountProvider.notifier).state =
                        //     account; // update state
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
