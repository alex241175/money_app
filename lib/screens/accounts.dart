import 'package:flutter/material.dart';
import 'package:money_app/screens/account_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_app/providers/database.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = ref.read(databaseProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AccountDetailScreen(isEdit: false),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: database.allAccounts,
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
              return Dismissible(
                onDismissed: (direction) async {
                  await database.removeAccount(id);
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
                    children: [Text(item['name']), Text(item['currency'])],
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => AccountDetailScreen(
                            isEdit: true,
                            id: id,
                            account: item,
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
