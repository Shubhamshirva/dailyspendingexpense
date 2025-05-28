import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int? id;
  final String name;

  const Category({this.id, required this.name});

  // Convert a Category object into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Extract a Category object from a Map.
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
    );
  }

  @override
  List<Object?> get props => [id, name];

  // Method to create a copy of the Category with updated fields
  Category copyWith({
    int? id,
    String? name,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}