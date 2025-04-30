import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farma_friend/model/pesticideModel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:translator/translator.dart';

class PesticideListPage extends StatefulWidget {
  const PesticideListPage({super.key});

  @override
  _PesticideListPageState createState() => _PesticideListPageState();
}

class _PesticideListPageState extends State<PesticideListPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(
          'Pesticides',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pesticides')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No pesticides available.'));
                }

                // Fetching all pesticides
                final pesticides = snapshot.data!.docs
                    .map((doc) => Pesticide.fromMap(
                        doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                // Filtering pesticides based on search query
                final filteredPesticides = pesticides.where((pesticide) {
                  return pesticide.name
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                }).toList();

                if (filteredPesticides.isEmpty) {
                  return const Center(child: Text('No pesticides found.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredPesticides.length,
                  itemBuilder: (context, index) {
                    return _buildPesticideCard(filteredPesticides[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search for a pesticide...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.green.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.green.shade700, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPesticideCard(Pesticide pesticide) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pesticide.name,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              pesticide.use,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 1),
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.07, // 10% of screen height
              width: MediaQuery.of(context).size.width *
                  0.27, // 25% of screen width
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(8), // Optional: for rounded corners
                child: Image.network(
                  pesticide.imageurl,
                  fit: BoxFit
                      .cover, // Ensures all images maintain the same aspect ratio and fill the space
                ),
              ),
            ),
            SizedBox(
              width: double.infinity, // Make button full width
              child: ElevatedButton(
                onPressed: () {
                  _showPesticideDetails(pesticide);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 5, // Reduced elevation for a subtler shadow
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Rounded button
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height *
                        0.0001, // 1% of screen height
                  ),
                ),
                child: Text(
                  'Show Details',
                  style: GoogleFonts.poppins(
                    fontSize: MediaQuery.of(context).size.width *
                        0.035, // 3.5% of screen width
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showPesticideDetails(Pesticide pesticide) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(pesticide.name),
          content: PesticideDetailsDialog(pesticide: pesticide),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class PesticideDetailsDialog extends StatefulWidget {
  final Pesticide pesticide;

  const PesticideDetailsDialog({super.key, required this.pesticide});

  @override
  _PesticideDetailsDialogState createState() => _PesticideDetailsDialogState();
}

class _PesticideDetailsDialogState extends State<PesticideDetailsDialog> {
  final GoogleTranslator translator = GoogleTranslator();
  String translatedUse = '';
  String selectedLanguage = 'mr'; // Default language set to Marathi
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
    // Translate the usage on initial load
    translateUsage();
  }

  // Function to translate the usage
  void translateUsage() async {
    try {
      var translation = await translator.translate(widget.pesticide.use,
          to: selectedLanguage);
      setState(() {
        translatedUse = translation.text;
      });
    } catch (e) {
      // Handle error (e.g., show a message or log the error)
      print('Translation error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300, // Set a width for the dialog
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            widget.pesticide.imageurl,
            fit: BoxFit.cover,
            height: 150,
            width: double.infinity,
          ),
          const SizedBox(height: 10),
          // Dropdown for language selection
          DropdownButton<String>(
            value: selectedLanguage,
            onChanged: (String? newValue) {
              setState(() {
                selectedLanguage = newValue!;
                translateUsage(); // Translate when a new language is selected
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
          const Text(
            'Usage:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            translatedUse.isNotEmpty ? translatedUse : widget.pesticide.use,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
