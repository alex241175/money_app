class Account {
  final String? id; // nullable
  final String name;
  final String currency;
  final String? note;

  Account({this.id, required this.name, required this.currency, this.note});

  // Override == and hashCode for content-based comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account &&
          runtimeType == other.runtimeType &&
          name == other.name; // Compare based on a unique identifier like 'code'

  @override
  int get hashCode => name.hashCode; // Use the same unique identifier for hashCode
}
