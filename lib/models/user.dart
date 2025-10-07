class User {
  final int id;
  final String fullName;
  final String email;
  final DateTime creationDate;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.creationDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_utilisateur'],
      fullName: json['nom_complet'],
      email: json['email'],
      creationDate: DateTime.parse(json['date_creation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_utilisateur': id,
      'nom_complet': fullName,
      'email': email,
      'date_creation': creationDate.toIso8601String(),
    };
  }
}
