class Category {
  final String? id; // nullable
  final String name;
  final String description;

  Category({this.id, required this.name, required this.description});

  // Override == and hashCode for content-based comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          name == other.name; // Compare based on a unique identifier like 'code'

  @override
  int get hashCode => name.hashCode; // Use the same unique identifier for hashCode
}
