import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:farma_friend/model/crop_model.dart';
import 'package:farma_friend/pages/ai.dart';
import 'package:farma_friend/pages/community_page.dart';
import 'package:farma_friend/pages/crop_details.dart';
import 'package:farma_friend/pages/crop_suggestion.dart';
import 'package:farma_friend/pages/login_page.dart';
import 'package:farma_friend/pages/pesticide_data_display_page.dart';
import 'package:farma_friend/pages/search_user_input.dart';
import 'package:farma_friend/pages/soil_data_display.dart';
import 'package:farma_friend/pages/soil_testing.dart';
import 'package:farma_friend/pages/user_profile_page.dart';
import 'package:farma_friend/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'add_data.dart';

class FarmerFriendApp extends StatelessWidget {
  const FarmerFriendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  final List<Widget> _pages = [
    const HomeContent(),
    const Center(child: Text('Search')),
    const Center(child: Text('Add')),
    const Center(child: Text('Profile')),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    var user = await _authService.getCurrentUser();
    if (user == null) {
      Navigator.pushReplacement(context as BuildContext,
          MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Call Firebase sign-out method
      await _authService.signOut();

      // Navigate to login page after successful sign-out
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("SucessFully LogOut")),
      );
    } catch (e) {
      print('Error during sign-out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _pages[_currentIndex], // Show the respective page for other indices
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // fixedColor: const Color.fromARGB(255, 238, 203, 225),
        selectedItemColor:
            const Color.fromARGB(255, 0, 64, 128), // Deep Royal Blue
        backgroundColor:
            const Color.fromARGB(255, 241, 205, 205), // Elegant Silver

        selectedLabelStyle: TextStyle(
          fontSize: 14, // Larger font size for selected item
          fontWeight: FontWeight.bold, // Bold text for selected item
          color: Colors.green[700], // Ensure color consistency
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12, // Smaller font size for unselected items
          fontWeight: FontWeight.normal, // Normal weight for unselected items
          color: Colors.grey, // Light gray for unselected
        ),
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            if (index == 4) {
              _navigateToProfile(context);
            } else if (index == 3) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CommunityPage()));
            } else if (index == 2) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ChatPage()));
            } else if (index == 1) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SearchOptionPage()));
            } else {
              _currentIndex = index;
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            tooltip: "Home Page",
            backgroundColor: Color.fromARGB(255, 235, 183, 183),
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            tooltip: "Search Crops And Pesticides",
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            tooltip: "Chat",
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sentiment_satisfied),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfilePage(userId: user.uid),
        ),
      );
    } else {
      // Optional: Show a dialog or navigate to Login Page if the user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to view your profile.')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const LoginPage()), // Replace with your Login Page
      );
    }
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  Map<String, List<Crop>> _seasonalCrops = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    _fetchCrops();
    _checkPostingPermission();
  }

  Future<void> _checkPostingPermission() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Query Firestore to check the canPost permission
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user.uid) // Assuming user ID matches the document ID
          .get();

      if (userDoc.exists) {
        setState(() {
          canPost = userDoc['canPost'] ??
              false; // Default to false if field is missing
        });
      }
    }
  }

  Future<void> _fetchCrops() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult != ConnectivityResult.none) {
      log("Connection ok");
      await _fetchCropsFromFirebase();
    } else {
      log("Connection not ok");
      await _fetchCropsFromLocalDb();
    }
  }

  Future<void> _fetchCropsFromFirebase() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var snapshot = await firestore.collection('crops').get();
      _seasonalCrops = {};

      for (var doc in snapshot.docs) {
        if (doc.data().containsKey('name') && doc.data()['name'] != null) {
          Crop crop = Crop(
            id: doc['id'] ?? '',
            name: doc['name'] ?? '',
            description: doc['description'] ?? '',
            pesticides: doc['pesticides'] ?? '',
            imageUrl: doc['imageUrl'] ?? '',
            season: doc['season'] ?? '',
            minNitrogenLevel: _toDouble(doc['minNitrogenLevel']),
            maxNitrogenLevel: _toDouble(doc['maxNitrogenLevel']),
            minPhosphorusLevel: _toDouble(doc['minPhosphorusLevel']),
            maxPhosphorusLevel: _toDouble(doc['maxPhosphorusLevel']),
            minPotassiumLevel: _toDouble(doc['minPotassiumLevel']),
            maxPotassiumLevel: _toDouble(doc['maxPotassiumLevel']),
            minMoisture: _toDouble(doc['minMoisture']),
            maxMoisture: _toDouble(doc['maxMoisture']),
            minTemperature: _toDouble(doc['minTemperature']),
            maxTemperature: _toDouble(doc['maxTemperature']),
            minPHLevel: _toDouble(doc['minPHLevel']),
            maxPHLevel: _toDouble(doc['maxPHLevel']),
            // New parameter
          );

          // Categorize crops by season
          if (!_seasonalCrops.containsKey(crop.season)) {
            _seasonalCrops[crop.season] = [];
          }
          _seasonalCrops[crop.season]!.add(crop);
        } else {
          log("Field 'name' does not exist or is null for document: ${doc.id}");
        }
      }
      setState(() {});
    } catch (e) {
      print("Home Page Error fetching from Firebase: $e");
    }
  }

  Future<void> _fetchCropsFromLocalDb() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'crops9.db'),
    );

    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('crops3');

    _seasonalCrops = {};

    for (var map in maps) {
      Crop crop = Crop(
        id: map['id'].toString(),
        name: map['name'],
        description: map['description'],
        pesticides: map['pesticides'],
        imageUrl: map['imageUrl'],
        season: map['season'],
        minNitrogenLevel: map['minNitrogenLevel'], // New parameter
        maxNitrogenLevel: map['maxNitrogenLevel'], // New parameter
        minPhosphorusLevel: map['minPhosphorusLevel'], // New parameter
        maxPhosphorusLevel: map['maxPhosphorusLevel'], // New parameter
        minPotassiumLevel: map['minPotassiumLevel'], // New parameter
        maxPotassiumLevel: map['maxPotassiumLevel'], // New parameter
        minMoisture: map['minMoisture'], // New parameter
        maxMoisture: map['maxMoisture'], // New parameter
        minTemperature: map['minTemperature'], // New parameter
        maxTemperature: map['maxTemperature'], // New parameter
        minPHLevel: map['minPHLevel'], // New parameter
        maxPHLevel: map['maxPHLevel'], // New parameter
      );

      // Categorize crops by season
      if (!_seasonalCrops.containsKey(crop.season)) {
        _seasonalCrops[crop.season] = [];
      }
      _seasonalCrops[crop.season]!.add(crop);
    }
    setState(() {});
  }

  bool canPost = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color.fromARGB(0, 41, 26, 26),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 15.0), // Increased bottom padding
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 255, 255, 255).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Farma Friend',
                  style: GoogleFonts.dancingScript(
                    letterSpacing: 1.7,
                    fontSize: 30.0, // You can adjust this size
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              background: Stack(
                children: [
                  Image.asset(
                    'assets/farmer_main.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(
                          0.6), // Darker overlay for better contrast
                    ),
                  ),
                  Positioned(
                    bottom: 5, // Adjusted position for better separation
                    left: 20,
                    child: Text(
                      'Your farming companion',
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureIconsSection(),
                  const SizedBox(height: 20),
                  _buildCarouselSection(context),
                  const SizedBox(height: 20),
                  for (var season in _seasonalCrops.keys)
                    _buildSeasonalSection(season, _seasonalCrops[season]!,
                        Colors.green[100]!, context),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: canPost
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddCropScreen())),
              backgroundColor: Colors.green[700],
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFeatureIconsSection() {
    return Builder(builder: (context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SoilDataEntryChoice()));
            },
            child: _buildFeatureIcon(Icons.water_drop_rounded, 'Soil Testing',
                Colors.blueAccent, context),
          ),
          GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CropListPage()));
              },
              child: _buildFeatureIcon(
                  Icons.eco, 'Crop Suggestion', Colors.orangeAccent, context)),
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PesticideListPage()));
            },
            child: _buildFeatureIcon(
                Icons.bug_report, 'Pesticides', Colors.greenAccent, context),
          ),
          GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => SoilDataDisplayPage()));
              },
              child: _buildFeatureIcon(
                  Icons.sensors, 'IoT Data', Colors.blueAccent, context)),
        ],
      );
    });
  }

  Widget _buildFeatureIcon(
      IconData icon, String label, Color bgColor, BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width *
            0.25, // Limit the max width to 25% of the screen width
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Use min size to prevent overflow
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: bgColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: FittedBox(
              child: Icon(
                icon,
                size: 30, // Static icon size, FittedBox handles scaling
                color: bgColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Use FittedBox for text to ensure it fits the available space
          FittedBox(
            child: Text(
              label,
              textAlign:
                  TextAlign.center, // Center align text for better appearance
              style: GoogleFonts.roboto(
                fontSize: 12, // Static font size, adjusted by FittedBox
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis, // Prevent overflow by truncating text
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselSection(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        enlargeCenterPage: true,
        height: MediaQuery.of(context).size.height * 0.22, // Responsive height
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 2),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.easeInOut,
      ),
      items: [
        {
          'image': 'assets/crop_rotation.png',
          'title': 'Crop Rotation',
          'onTap': () {
            // Define the functionality when this card is tapped
            print('Crop Rotation tapped');
          },
        },
        {
          'image': 'assets/iot_sensor.png',
          'title': 'IoT Sensor',
          'onTap': () {
            // Define the functionality when this card is tapped
            print('IoT Sensor tapped');
          },
        },
        {
          'image': 'assets/soil_test.jpg',
          'title': 'Soil Testing',
          'onTap': () {
            // Define the functionality when this card is tapped
            print('Soil Testing tapped');
          },
        },
      ].map((item) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: item['onTap']
                  as GestureTapCallback?, // Call the onTap function
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4), // changes position of shadow
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(item['image'] as String),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 15,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildSeasonalSection(
      String season, List<Crop> crops, Color color, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 10.0), // Added padding for better spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$season Crops",
            style: GoogleFonts.poppins(
              fontSize: 24, // Increased font size for better visibility
              fontWeight: FontWeight.bold,
              color: const Color(
                  0xFF2C3E50), // Use the passed color for consistency
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220, // Height for the crop cards
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: crops.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(
                      right: 12.0), // Spacing between cards
                  child: _buildCropCard(crops[index], color, context),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// Crop Card with enhanced visuals
  Widget _buildCropCard(Crop crop, Color color, BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      color: color,
      margin: const EdgeInsets.only(right: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4, // 40% of screen width
        height:
            MediaQuery.of(context).size.height * 0.2, // 20% of screen height
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'crop_image_${crop.id}', // Unique tag for the crop image
              child: SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.1, // 10% of screen height
                width: MediaQuery.of(context).size.width *
                    0.25, // 25% of screen width
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(8), // Optional: for rounded corners
                  child: Image.network(
                    crop.imageUrl,
                    fit: BoxFit
                        .cover, // Ensures all images maintain the same aspect ratio and fill the space
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              crop.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
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

  double _toDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0; // Return 0.0 if parsing fails
    } else if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    }
    return 0.0; // Default to 0.0 if the value is of an unexpected type
  }
}
