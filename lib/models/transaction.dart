import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String? id; // nullable
  final String category;
  final String account;
  final DateTime dateTime;
  final String currency;
  final double amount;
  final String? note;

  Transaction({
    this.id, // optional
    required this.category,
    required this.account,
    required this.dateTime,
    required this.currency,
    required this.amount,
    this.note,
  });

  // Factory constructor to create a Transaction from a DocumentSnapshot
  factory Transaction.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    final data = doc.data()!; // Get the map data. '!' asserts it's not null.
    return Transaction(
      id: doc.id, // The document ID is separate from the data map
      category: data['category'] ?? '',
      account: data['account'] ?? '',
      currency: data['currency'] ?? '',
      amount: data['amount'].toDouble() ?? 0.0,
      dateTime: data['dateTime'].toDate() ?? DateTime.now(),
      note: data['note'] ?? '',
    );
  }
}
