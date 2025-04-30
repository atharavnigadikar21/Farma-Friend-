class Crop {
  final String id;
  final String name;
  final String description;
  final String pesticides;
  final String imageUrl;
  final String season;

  // New soil parameters with min and max fields
  final double minNitrogenLevel;
  final double maxNitrogenLevel;
  final double minPhosphorusLevel;
  final double maxPhosphorusLevel;
  final double minPotassiumLevel;
  final double maxPotassiumLevel;
  final double minMoisture;
  final double maxMoisture;
  final double minTemperature;
  final double maxTemperature;
  final double minPHLevel;
  final double maxPHLevel;

  Crop({
    this.id = '',
    required this.name,
    required this.description,
    required this.pesticides,
    required this.imageUrl,
    required this.season,
    required this.minNitrogenLevel,
    required this.maxNitrogenLevel,
    required this.minPhosphorusLevel,
    required this.maxPhosphorusLevel,
    required this.minPotassiumLevel,
    required this.maxPotassiumLevel,
    required this.minMoisture,
    required this.maxMoisture,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minPHLevel,
    required this.maxPHLevel,
  });

  // Convert Crop object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pesticides': pesticides,
      'imageUrl': imageUrl,
      'season': season,
      'minNitrogenLevel': minNitrogenLevel,
      'maxNitrogenLevel': maxNitrogenLevel,
      'minPhosphorusLevel': minPhosphorusLevel,
      'maxPhosphorusLevel': maxPhosphorusLevel,
      'minPotassiumLevel': minPotassiumLevel,
      'maxPotassiumLevel': maxPotassiumLevel,
      'minMoisture': minMoisture,
      'maxMoisture': maxMoisture,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'minPHLevel': minPHLevel,
      'maxPHLevel': maxPHLevel,
    };
  }

  // Create Crop object from Map
  factory Crop.fromMap(Map<String, dynamic> map) {
    return Crop(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      pesticides: map['pesticides'],
      imageUrl: map['imageUrl'],
      season: map['season'],
      minNitrogenLevel: _toDouble(map['minNitrogenLevel']),
      maxNitrogenLevel: _toDouble(map['maxNitrogenLevel']),
      minPhosphorusLevel: _toDouble(map['minPhosphorusLevel']),
      maxPhosphorusLevel: _toDouble(map['maxPhosphorusLevel']),
      minPotassiumLevel: _toDouble(map['minPotassiumLevel']),
      maxPotassiumLevel: _toDouble(map['maxPotassiumLevel']),
      minMoisture: _toDouble(map['minMoisture']),
      maxMoisture: _toDouble(map['maxMoisture']),
      minTemperature: _toDouble(map['minTemperature']),
      maxTemperature: _toDouble(map['maxTemperature']),
      minPHLevel: _toDouble(map['minPHLevel']),
      maxPHLevel: _toDouble(map['maxPHLevel']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0; // Return 0.0 if parsing fails
    } else if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    }
    return 0.0; // Default to 0.0 if the value is of an unexpected type
  }

  // Check if the provided soil parameters are suitable for the crop
  bool isSuitable({
    required double userNitrogen,
    required double userPhosphorus,
    required double userPotassium,
    required double userMoisture,
    required double userTemperature,
    required double userPH,
  }) {
    return (userNitrogen >= minNitrogenLevel &&
        userNitrogen <= maxNitrogenLevel &&
        userPhosphorus >= minPhosphorusLevel &&
        userPhosphorus <= maxPhosphorusLevel &&
        userPotassium >= minPotassiumLevel &&
        userPotassium <= maxPotassiumLevel &&
        userMoisture >= minMoisture &&
        userMoisture <= maxMoisture &&
        userTemperature >= minTemperature &&
        userTemperature <= maxTemperature &&
        userPH >= minPHLevel &&
        userPH <= maxPHLevel);
  }

  @override
  String toString() {
    return 'Crop(id: $id, name: $name, description: $description, pesticides: $pesticides, imageUrl: $imageUrl, season: $season, '
        'minNitrogenLevel: $minNitrogenLevel, maxNitrogenLevel: $maxNitrogenLevel, '
        'minPhosphorusLevel: $minPhosphorusLevel, maxPhosphorusLevel: $maxPhosphorusLevel, '
        'minPotassiumLevel: $minPotassiumLevel, maxPotassiumLevel: $maxPotassiumLevel, '
        'minMoisture: $minMoisture, maxMoisture: $maxMoisture, '
        'minTemperature: $minTemperature, maxTemperature: $maxTemperature, '
        'minPHLevel: $minPHLevel, maxPHLevel: $maxPHLevel)';
  }
}
