import 'package:farma_friend/model/crop_model.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class CropDetails extends StatefulWidget {
  final Crop crop;

  const CropDetails({super.key, required this.crop});

  @override
  _CropDetailsState createState() => _CropDetailsState();
}

class _CropDetailsState extends State<CropDetails> {
  GoogleTranslator translator = GoogleTranslator();
  String translatedDescription = '';
  String translatedSoilParameters = '';
  String translatedPesticides = '';
  String translatedSeason = '';
  String selectedLanguage = 'en'; // Default language
  final Map<String, String> languages = {
    'English': 'en',
    'Marathi': 'mr',
    'Hindi': 'hi',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Chinese': 'zh',
    'Japanese': 'ja',
    // Add more languages as needed
  };

  @override
  void initState() {
    super.initState();
    // Translate the description and other fields on initial load
    translateFields();
  }

  // Function to translate fields
  void translateFields() async {
    var descriptionTranslation = await translator
        .translate(widget.crop.description, to: selectedLanguage);
    var soilParametersTranslation = await translator.translate(
      'pH Level-${widget.crop.minPHLevel} to ${widget.crop.maxPHLevel}, Moisture-${widget.crop.minMoisture} to ${widget.crop.maxMoisture}, Temperature-${widget.crop.minTemperature} to ${widget.crop.maxTemperature}, Nitrogen-${widget.crop.minNitrogenLevel} to ${widget.crop.maxNitrogenLevel}, Phosphorus-${widget.crop.minPhosphorusLevel} to ${widget.crop.maxPhosphorusLevel}, Potassium-${widget.crop.minPotassiumLevel} to ${widget.crop.maxPotassiumLevel}',
      to: selectedLanguage,
    );
    var pesticidesTranslation = await translator
        .translate(widget.crop.pesticides, to: selectedLanguage);
    var seasonTranslation =
        await translator.translate(widget.crop.season, to: selectedLanguage);

    setState(() {
      translatedDescription = descriptionTranslation.text;
      translatedSoilParameters = soilParametersTranslation.text;
      translatedPesticides = pesticidesTranslation.text;
      translatedSeason = seasonTranslation.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crop.name),
        backgroundColor: Colors.green[700],
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: 'crop_${widget.crop.id}', // Unique tag for the crop image
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(widget.crop.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.crop.name,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 10),

              // Dropdown for language selection
              DropdownButton<String>(
                value: selectedLanguage,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLanguage = newValue!;
                    translateFields(); // Translate when a new language is selected
                  });
                },
                items: languages.entries.map<DropdownMenuItem<String>>((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.value,
                    child: Text(entry.key),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      translatedDescription.isNotEmpty
                          ? translatedDescription
                          : widget.crop.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Divider(height: 30, thickness: 1),
                    Row(
                      children: [
                        Text(
                          'Soil Parameters',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                        Icon(Icons.sensors_sharp, color: Colors.green[700]),
                      ],
                    ),
                    Text(
                      translatedSoilParameters.isNotEmpty
                          ? translatedSoilParameters.replaceAll(',',
                              '\n') // Assuming translated parameters are comma-separated
                          : '  pH Level: ${widget.crop.minPHLevel} to ${widget.crop.maxPHLevel}\n'
                              'Moisture: ${widget.crop.minMoisture} to ${widget.crop.maxMoisture}\n'
                              'Temperature: ${widget.crop.minTemperature} to ${widget.crop.maxTemperature}\n'
                              'Nitrogen: ${widget.crop.minNitrogenLevel} to ${widget.crop.maxNitrogenLevel}\n'
                              'Phosphorus: ${widget.crop.minPhosphorusLevel} to ${widget.crop.maxPhosphorusLevel}\n'
                              'Potassium: ${widget.crop.minPotassiumLevel} to ${widget.crop.maxPotassiumLevel}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Divider(height: 30, thickness: 1),
                    Row(
                      children: [
                        Text(
                          'Pesticides',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                        Icon(Icons.bug_report, color: Colors.green[700]),
                      ],
                    ),
                    Text(
                      translatedPesticides.isNotEmpty
                          ? translatedPesticides
                          : widget.crop.pesticides,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Divider(height: 30, thickness: 1),
                    Row(
                      children: [
                        Text(
                          'Season',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[900],
                          ),
                        ),
                        Icon(Icons.calendar_today, color: Colors.green[700]),
                      ],
                    ),
                   Text(
                      translatedSeason.isNotEmpty
                          ? translatedSeason
                          : widget.crop.season,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  // Additional actions (if needed)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.info_outline),
                label: const Text(
                  'More Information',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
