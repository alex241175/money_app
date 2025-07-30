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
}
