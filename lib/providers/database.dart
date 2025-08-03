import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:money_app/models/transaction.dart' as money_app;
import 'package:money_app/models/account.dart';
import 'package:money_app/models/category.dart';

class Database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _transactions;
  CollectionReference? _accounts;
  CollectionReference? _categories;

  // get all transactions
  Future get allTransactions =>
      _firestore //return a querysnapshot
          .collection("transactions")
          .orderBy('dateTime', descending: true)
          .get();

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

  // get all accounts
  Future get allAccounts =>
      _firestore.collection("accounts").orderBy('name').get();

  // Add an account
  Future<bool> addNewAccount(Account a) async {
    _accounts = _firestore.collection(
      'accounts',
    ); // referencing the transactions collection .
    try {
      await _accounts!.add({
        'name': a.name,
        'currency': a.currency,
      }); // Adding a new document to our movies collection
      return true; // finally return true
    } catch (e) {
      return Future.error(e); // return error
    }
  }

  // Remove an account
  Future<bool> removeAccount(String id) async {
    _accounts = _firestore.collection('accounts');
    try {
      await _accounts!.doc(id).delete();
      return true; // return true after successful deletion .
    } catch (e) {
      return Future.error(e); // return error
    }
  }

  // Edit an account
  Future<bool> editAccount(Account a, String id) async {
    _accounts = _firestore.collection('accounts');
    try {
      await _accounts!.doc(id).update(
        // updates the document having id of id
        {'currency': a.currency, 'name': a.name},
      );
      return true; //// return true after successful updation .
    } catch (e) {
      return Future.error(e); //return error
    }
  }

  // get all categories
  Future get allCategories =>
      _firestore.collection("categories").orderBy('name').get();

  // Add an account
  Future<bool> addNewCategory(Category c) async {
    _categories = _firestore.collection(
      'categories',
    ); // referencing the transactions collection .
    try {
      await _categories!.add({
        'name': c.name,
        'description': c.description,
      }); // Adding a new document to our movies collection
      return true; // finally return true
    } catch (e) {
      return Future.error(e); // return error
    }
  }

  // Remove a category
  Future<bool> removeCategory(String id) async {
    _categories = _firestore.collection('categories');
    try {
      await _categories!.doc(id).delete();
      return true; // return true after successful deletion .
    } catch (e) {
      return Future.error(e); // return error
    }
  }

  // Edit a category
  Future<bool> editCategory(Category c, String id) async {
    _categories = _firestore.collection('categories');
    try {
      await _categories!.doc(id).update(
        // updates the document having id of id
        {'description': c.description, 'name': c.name},
      );
      return true; //// return true after successful updation .
    } catch (e) {
      return Future.error(e); //return error
    }
  }
}

final databaseProvider = Provider((ref) => Database());
