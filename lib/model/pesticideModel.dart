class Pesticide {
  final String id;
  final String name;
  final String use;
  final String imageurl;

  Pesticide({
    required this.id,
    required this.name,
    required this.use,
    required this.imageurl,
  });

  factory Pesticide.fromMap(Map<String, dynamic> map, String documentId) {
    return Pesticide(
      id: documentId,
      name: map['name'] ?? '',
      use: map['use'] ?? '',
      imageurl: map['imageurl'] ?? '',
    );
  }
}
