import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farma_friend/model/crop_model.dart';
import 'package:farma_friend/pages/crop_details.dart';
// Ensure you have a CropDetails page defined
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CropListPage extends StatefulWidget {
  const CropListPage({super.key});

  @override
  _CropListPageState createState() => _CropListPageState();
}

class _CropListPageState extends State<CropListPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(
          'Crops',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('crops').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No crops available.'));
                }

                // Fetching all crops
                final crops = snapshot.data!.docs
                    .map((doc) => Crop.fromMap(
                          doc.data() as Map<String, dynamic>,
                        ))
                    .toList();

                // Filtering crops based on search query
                final filteredCrops = crops.where((crop) {
                  return crop.name
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                }).toList();

                if (filteredCrops.isEmpty) {
                  return const Center(child: Text('Crop not found.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filteredCrops.length,
                  itemBuilder: (context, index) {
                    return _buildCropCard(filteredCrops[index], context);
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
          hintText: 'Search for a crop...',
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

  Widget _buildCropCard(Crop crop, BuildContext context) {
    return Card(
      elevation: 3, // Reduced elevation for a subtler shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Padding(
        padding: EdgeInsets.all(
            MediaQuery.of(context).size.width * 0.03), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Responsive font size for crop name
            Text(
              crop.name,
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width *
                    0.045, // 4.5% of screen width
                fontWeight: FontWeight.bold,
                color: Colors.green[800], // Classy color for crop name
              ),
              overflow: TextOverflow.ellipsis, // Prevent overflow
              maxLines: 1, // Limit to 1 line
            ),
            const SizedBox(height: 5), // Reduced height for spacing
            // Responsive font size for crop description
            Text(
              crop.description,
              style: GoogleFonts.poppins(
                fontSize: MediaQuery.of(context).size.width *
                    0.035, // 3.5% of screen width
                color: Colors.grey[600], // Slightly darker grey
              ),
              maxLines: 2, // Limit to 2 lines
              overflow: TextOverflow.ellipsis, // Prevent overflow
            ),
            const SizedBox(height: 10), // Spacing before button
            // Elevated button with responsive size
            SizedBox(
              width: double.infinity, // Make button full width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CropDetails(
                        crop: crop,
                      ),
                    ),
                  );
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
                        0.01, // 1% of screen height
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
            ),
          ],
        ),
      ),
    );
  }
}
