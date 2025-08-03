import 'package:flutter/material.dart';
import 'package:money_app/screens/category_detail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_app/providers/database.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  Future<dynamic>? _futureData;

  @override
  void initState() {
    super.initState();
    final database = ref.read(databaseProvider);
    setState(() {
      _futureData = database.allCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.read(databaseProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (ctx) =>
                          const CategoryDetailScreen(isEdit: false),
                    ),
                  )
                  .then((value) {
                    // this code runs when secondscreen is popped
                    setState(() {
                      _futureData = database.allCategories;
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
              final item = items[index];
              final String id = items[index]['id'];
              return Dismissible(
                onDismissed: (direction) async {
                  await database.removeCategory(id);
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
                      Text(item['name']),
                      Text(
                        item['description'],
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (ctx) => CategoryDetailScreen(
                                isEdit: true,
                                id: id,
                                category: item,
                              ),
                            ),
                          )
                          .then((value) {
                            // this code runs when secondscreen is popped
                            setState(() {
                              _futureData = database.allCategories;
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
