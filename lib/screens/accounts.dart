import 'package:flutter/material.dart';
import 'package:money_app/screens/account_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_app/providers/database.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  Future<dynamic>? _futureData;

  @override
  void initState() {
    super.initState();
    final database = ref.read(databaseProvider);
    setState(() {
      _futureData = database.allAccounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.read(databaseProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (ctx) =>
                          const AccountDetailScreen(isEdit: false),
                    ),
                  )
                  .then((value) {
                    // this code runs when secondscreen is popped
                    setState(() {
                      _futureData = database.allAccounts;
                    });
                  });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _futureData,
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

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, index) {
              var item = items[index];
              final String id = items[index]['id'];
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
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (ctx) => AccountDetailScreen(
                                isEdit: true,
                                id: id,
                                account: item,
                              ),
                            ),
                          )
                          .then((value) {
                            // this code runs when secondscreen is popped
                            setState(() {
                              _futureData = database.allAccounts;
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
