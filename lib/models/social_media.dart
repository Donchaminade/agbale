class SocialMedia {
  final int id;
  final int contactId;
  final String platform;
  final String link;

  SocialMedia({
    required this.id,
    required this.contactId,
    required this.platform,
    required this.link,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      id: json['id_social'],
      contactId: json['id_contact'],
      platform: json['plateforme'],
      link: json['lien'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_social': id,
      'id_contact': contactId,
      'plateforme': platform,
      'lien': link,
    };
  }
}
