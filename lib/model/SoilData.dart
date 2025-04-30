class SoilData {
  final int? id;
  final String ph;
  final String moisture;
  final String temp;
  final String nitrogen;
  final String phosphorus;
  final String potassium;
  final String? date;

  SoilData({
    this.id,
    required this.ph,
    required this.moisture,
    required this.temp,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.date,
  });

  // Convert SoilData object to Map
  Map<String, dynamic> toMap() {
    return {
      'ph': ph,
      'moisture': moisture,
      'temp': temp,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'date': date,
    };
  }

  // Create SoilData object from Map
  factory SoilData.fromMap(Map<String, dynamic> map) {
    return SoilData(
      id: map['id'],
      ph: map['ph'],
      moisture: map['moisture'],
      temp: map['temp'],
      nitrogen: map['nitrogen'],
      phosphorus: map['phosphorus'],
      potassium: map['potassium'],
      date: map['date'],
    );
  }

  @override
  String toString() {
    return 'SoilData{id: $id, ph: $ph, moisture: $moisture, temp: $temp, nitrogen: $nitrogen, phosphorus: $phosphorus, potassium: $potassium, date: $date}';
  }
}
