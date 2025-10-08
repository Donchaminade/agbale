class Contact {
  final int id;
  final int userId;
  final String contactName;
  final String? number;
  final String? email;
  final String importanceNote;
  final DateTime dateAdded;

  Contact({
    required this.id,
    required this.userId,
    required this.contactName,
    this.number,
    this.email,
    required this.importanceNote,
    required this.dateAdded,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id_contact'],
      userId: json['id_utilisateur'],
      contactName: json['nom_contact'],
      number: json['numero'],
      email: json['email'],
      importanceNote: json['note_importance'],
      dateAdded: DateTime.parse(json['date_ajout']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_contact': id,
      'id_utilisateur': userId,
      'nom_contact': contactName,
      'numero': number,
      'email': email,
      'note_importance': importanceNote,
      'date_ajout': dateAdded.toIso8601String(),
    };
  }

  Contact copyWith({
    int? id,
    int? userId,
    String? contactName,
    String? number,
    String? email,
    String? importanceNote,
    DateTime? dateAdded,
  }) {
    return Contact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contactName: contactName ?? this.contactName,
      number: number ?? this.number,
      email: email ?? this.email,
      importanceNote: importanceNote ?? this.importanceNote,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
