class Note {
  late int id;
  String title;
  String description;
  DateTime createdAt;
  DateTime? lastUpdatedAt;

  Note._({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.lastUpdatedAt,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note._(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: map['createdAt'],
      lastUpdatedAt: map['lastUpdatedAt'],
    );
  }
}
