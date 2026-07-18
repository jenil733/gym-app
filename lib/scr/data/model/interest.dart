class Interest {
  final String id;
  final String name;
  bool isSelected;

  Interest({required this.id, required this.name, this.isSelected = false});

  Interest copyWith({String? id, String? name, bool? isSelected}) {
    return Interest(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  String toString() =>
      'Interest(id: $id, name: $name, isSelected: $isSelected)';
}
