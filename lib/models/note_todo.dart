class NoteTodo {
  final int id;
  final int userId;
  final String title;
  final String? content;
  final String type; // 'note' or 'todo'
  final String status; // 'en_attente', 'en_cours', 'terminé'
  final DateTime creationDate;
  final DateTime? dueDate;

  NoteTodo({
    required this.id,
    required this.userId,
    required this.title,
    this.content,
    required this.type,
    required this.status,
    required this.creationDate,
    this.dueDate,
  });

  factory NoteTodo.fromJson(Map<String, dynamic> json) {
    return NoteTodo(
      id: json['id_note'],
      userId: json['id_utilisateur'],
      title: json['titre'],
      content: json['contenu'],
      type: json['type'],
      status: json['statut'],
      creationDate: DateTime.parse(json['date_creation']),
      dueDate: json['date_echeance'] != null ? DateTime.parse(json['date_echeance']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_note': id,
      'id_utilisateur': userId,
      'titre': title,
      'contenu': content,
      'type': type,
      'statut': status,
      'date_creation': creationDate.toIso8601String(),
      'date_echeance': dueDate?.toIso8601String(),
    };
  }

  NoteTodo copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
    String? type,
    String? status,
    DateTime? creationDate,
    DateTime? dueDate,
  }) {
    return NoteTodo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      creationDate: creationDate ?? this.creationDate,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
