import 'package:farma_friend/model/SoilData.dart';
import 'package:farma_friend/services/crop_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import your SoilData model class

class SoilDataDisplayPage extends StatelessWidget {
  SoilDataDisplayPage({super.key});
  final cropService = CropService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(
          'Soil Data Entries',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<List<SoilData>>(
        future:
            cropService.fetchAllSoilData(), // Fetch data from local database
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No soil data available.'));
          }

          final soilDataList = snapshot.data!;

          return ListView.builder(
            itemCount: soilDataList.length,
            itemBuilder: (context, index) {
              return _buildSoilDataCard(soilDataList[index]);
            },
          );
        },
      ),
    );
  }

  // Function to build individual Soil Data Card
  Widget _buildSoilDataCard(SoilData soilData) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soil Data Entry- ${soilData.id}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            const SizedBox(height: 10),
            _buildDetailRow('pH Level:', soilData.ph),
            _buildDetailRow('Moisture (%):', soilData.moisture),
            _buildDetailRow('Temperature:', soilData.temp),
            _buildDetailRow('Nitrogen Level:', soilData.nitrogen),
            _buildDetailRow('Phosphorus Level:', soilData.phosphorus),
            _buildDetailRow('Potassium Level:', soilData.potassium),
            _buildDetailRow('Date of Testing:', soilData.date as String),
          ],
        ),
      ),
    );
  }

  // Function to build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
