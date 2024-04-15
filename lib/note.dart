class Note {
  late int? id;
  String title;
  String description;
  DateTime createdAt;

  Note._({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory Note.create({required String title, required String description}) {
    return Note._(
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note._(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }
}
