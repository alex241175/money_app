import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_app/models/transaction.dart' as money_app;

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _transactions;

  Stream get allTransactions => _firestore
      .collection("transactions")
      .orderBy('dateTime', descending: true)
      .snapshots();

  // Add a transaction
  Future<bool> addNewTransaction(money_app.Transaction t) async {
    _transactions = _firestore.collection(
      'transactions',
    ); // referencing the transactions collection .
    try {
      await _transactions!.add({
        'category': t.category,
        'account': t.account,
        'dateTime': t.dateTime,
        'currency': t.currency,
        'amount': t.amount,
        'note': t.note,
      }); // Adding a new document to our movies collection
      return true; // finally return true
    } catch (e) {
      return Future.error(e); // return error
    }
  }

  // Remove a Transaction
  Future<bool> removeTransaction(String id) async {
    _transactions = _firestore.collection('transactions');
    try {
      await _transactions!
          .doc(id)
          .delete(); // deletes the document with id of movieId from our movies collection
      return true; // return true after successful deletion .
    } catch (e) {
      return Future.error(e); // return error
    }
  }

  // Edit a transaction
  Future<bool> editTransaction(money_app.Transaction t, String id) async {
    _transactions = _firestore.collection('transactions');
    try {
      await _transactions!.doc(id).update(
        // updates the document having id of id
        {
          'category': t.category,
          'account': t.account,
          'dateTime': t.dateTime,
          'currency': t.currency,
          'amount': t.amount,
          'note': t.note,
        },
      );
      return true; //// return true after successful updation .
    } catch (e) {
      return Future.error(e); //return error
    }
  }
}

final databaseProvider = Provider((ref) => Database());
