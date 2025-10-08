class MyNet {
  final int id;
  final int userId;
  final String siteName;
  final String username;
  final String? associatedEmailOrNumber;
  final String password;
  final DateTime creationDate;

  MyNet({
    required this.id,
    required this.userId,
    required this.siteName,
    required this.username,
    this.associatedEmailOrNumber,
    required this.password,
    required this.creationDate,
  });

  factory MyNet.fromJson(Map<String, dynamic> json) {
    return MyNet(
      id: json['id_mynet'],
      userId: json['id_utilisateur'],
      siteName: json['nom_site'],
      username: json['nom_utilisateur'],
      associatedEmailOrNumber: json['email_ou_numero'],
      password: json['mot_de_passe'],
      creationDate: DateTime.parse(json['date_creation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_mynet': id,
      'id_utilisateur': userId,
      'nom_site': siteName,
      'nom_utilisateur': username,
      'email_ou_numero': associatedEmailOrNumber,
      'mot_de_passe': password,
      'date_creation': creationDate.toIso8601String(),
    };
  }

  MyNet copyWith({
    int? id,
    int? userId,
    String? siteName,
    String? username,
    String? associatedEmailOrNumber,
    String? password,
    DateTime? creationDate,
  }) {
    return MyNet(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      siteName: siteName ?? this.siteName,
      username: username ?? this.username,
      associatedEmailOrNumber: associatedEmailOrNumber ?? this.associatedEmailOrNumber,
      password: password ?? this.password,
      creationDate: creationDate ?? this.creationDate,
    );
  }
}