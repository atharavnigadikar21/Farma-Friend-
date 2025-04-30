import 'package:farma_friend/model/SoilData.dart';
import 'package:farma_friend/model/crop_model.dart';
import 'package:farma_friend/pages/crop_details.dart';
import 'package:farma_friend/pages/home_page.dart';
import 'package:farma_friend/services/crop_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CropRecommendationPage extends StatelessWidget {
  final SoilData soilData;

  const CropRecommendationPage({super.key, required this.soilData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recommended Crops',
          style: GoogleFonts.poppins(fontSize: 22),
        ),
      ),
      body: FutureBuilder<List<Crop>>(
        future: _fetchCrops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final crops = snapshot.data!;

            final recommendedCrops = crops.where((crop) {
              return crop.isSuitable(
                userNitrogen: _toDouble(soilData.nitrogen),
                userPhosphorus: _toDouble(soilData.phosphorus),
                userPotassium: _toDouble(soilData.potassium),
                userMoisture: _toDouble(soilData.moisture),
                userTemperature: _toDouble(soilData.temp),
                userPH: _toDouble(soilData.ph),
              );
            }).toList();

            if (recommendedCrops.isEmpty) {
              // Show a message and navigate to the home page after a delay
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text('No recommended crops found.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const FarmerFriendApp()),
                            );
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              });
              return const SizedBox
                  .shrink(); // Return an empty widget to avoid layout issues
            } else {
              return ListView.builder(
                itemCount: recommendedCrops.length,
                itemBuilder: (context, index) {
                  final crop = recommendedCrops[index];
                  return _buildCropCard(context, crop);
                },
              );
            }
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }

  Future<List<Crop>> _fetchCrops() async {
    final cropService = CropService();
    return await cropService.fetchCropsFromFirebase();
  }

  Widget _buildCropCard(BuildContext context, Crop crop) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                crop.imageUrl, // Ensure this URL is valid
                height: 150.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              crop.name,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to Crop Details Page
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => CropDetails(
                            crop: crop,
                          )),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600], // Button color
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text(
                "Show Details",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _toDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ??
          0.0; // If conversion fails, return a default value
    } else if (value is int) {
      return value.toDouble(); // Convert int to double
    } else if (value is double) {
      return value; // Already a double, return as-is
    }
    return 0.0; // Default to 0.0 for unexpected types
  }
}
