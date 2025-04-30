import 'dart:developer';

import 'package:farma_friend/model/SoilData.dart';
import 'package:farma_friend/pages/compare.dart';
import 'package:farma_friend/pages/iotdata.dart';
import 'package:farma_friend/services/crop_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SoilDataEntryChoice extends StatelessWidget {
  const SoilDataEntryChoice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Choose Entry Method',
          style: GoogleFonts.poppins(
              fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF81C784), Color(0xFF66BB6A)],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 100.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon and Title
                Icon(Icons.agriculture,
                    size: 120, color: Colors.white.withOpacity(0.8)),
                const SizedBox(height: 20),
                Text(
                  'How would you like to enter soil data?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),

                // IoT Sensor Button
                _buildChoiceButton(
                  context,
                  'Enter via IoT Sensor',
                  Icons.sensors,
                  Colors.greenAccent,
                  const SoilDataInputPageIot(),
                ),
                const SizedBox(height: 20),

                // Manual Entry Button
                _buildChoiceButton(
                  context,
                  'Enter Manually',
                  Icons.edit,
                  Colors.orangeAccent,
                  const SoilDataInputPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Reusable method to create stylish buttons
  Widget _buildChoiceButton(
    BuildContext context,
    String label,
    IconData icon,
    Color iconColor,
    Widget nextPage,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8,
        shadowColor: Colors.black45,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// IoT Sensor Data Entry Page
class IoTDataEntryPage extends StatelessWidget {
  const IoTDataEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IoT Data Entry')),
      body: const Center(child: Text('IoT Sensor Data Entry Screen')),
    );
  }
}

// Soil Data Input Page
class SoilDataInputPage extends StatelessWidget {
  const SoilDataInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Text(
          'Soil Data Input',
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SoilDataForm(),
        ),
      ),
    );
  }
}

class SoilDataForm extends StatefulWidget {
  const SoilDataForm({super.key});

  @override
  _SoilDataFormState createState() => _SoilDataFormState();
}

class _SoilDataFormState extends State<SoilDataForm> {
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _moistureController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorusController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Enter Soil Data'),
        _buildSoilFactorInput(
            'pH Level', 'Enter pH (e.g., 6.5)', _phController, _validatePh),
        _buildSoilFactorInput('Moisture', 'Enter Moisture % (e.g., 30%)',
            _moistureController, _validateMoisture),
        _buildSoilFactorInput('Temperature', 'Enter temp (e.g., 22°C)',
            _tempController, _validateTemperature),
        _buildSoilFactorInput('Nitrogen Level', 'Enter N (e.g., 40 mg/kg)',
            _nitrogenController, _validateNitrogen),
        _buildSoilFactorInput('Phosphorus Level', 'Enter P (e.g., 20 mg/kg)',
            _phosphorusController, _validatePhosphorus),
        _buildSoilFactorInput('Potassium Level', 'Enter K (e.g., 50 mg/kg)',
            _potassiumController, _validatePotassium),
        _buildDateField(),
        const SizedBox(height: 20),
        _buildSubmitButton(),
      ],
    );
  }

  // Title for the form
  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.green[800],
        ),
      ),
    );
  }

  // Custom input field for each soil factor
  Widget _buildSoilFactorInput(String label, String hint,
      TextEditingController controller, String Function(String) validator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: Colors.green.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: Colors.green.shade700, width: 1.5),
              ),
            ),
            keyboardType: TextInputType.text,
            onChanged: (value) {
              final errorMessage = validator(value);
              if (errorMessage.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // Validate pH level
  String _validatePh(String value) {
    final double? phValue = double.tryParse(value);
    if (phValue == null || phValue < 5.0 || phValue > 8.5) {
      return 'Enter a valid pH level between 5.0 and 8.5';
    }
    return '';
  }

  // Validate moisture percentage
  String _validateMoisture(String value) {
    final int? moistureValue = int.tryParse(value.replaceAll('%', ''));
    if (moistureValue == null || moistureValue < 0 || moistureValue > 100) {
      return 'Enter valid moisture percentage (0-100)';
    }
    return '';
  }

  // Validate temperature
  String _validateTemperature(String value) {
    final double? tempValue = double.tryParse(value.replaceAll('°C', ''));
    if (tempValue == null || tempValue < 0 || tempValue > 50) {
      return 'Enter a valid temperature between 0°C and 50°C';
    }
    return '';
  }

  // Validate nitrogen level
  String _validateNitrogen(String value) {
    final double? nitrogenValue =
        double.tryParse(value.replaceAll('mg/kg', ''));
    if (nitrogenValue == null || nitrogenValue < 0) {
      return 'Enter a valid nitrogen level';
    }
    return '';
  }

  // Validate phosphorus level
  String _validatePhosphorus(String value) {
    final double? phosphorusValue =
        double.tryParse(value.replaceAll('mg/kg', ''));
    if (phosphorusValue == null || phosphorusValue < 0) {
      return 'Enter a valid phosphorus level';
    }
    return '';
  }

  // Validate potassium level
  String _validatePotassium(String value) {
    final double? potassiumValue =
        double.tryParse(value.replaceAll('mg/kg', ''));
    if (potassiumValue == null || potassiumValue < 0) {
      return 'Enter a valid potassium level';
    }
    return '';
  }

  // Date field for selecting the date
  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date of Entry',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Select Date',
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: Colors.green.shade200, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: Colors.green.shade700, width: 1.5),
              ),
            ),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                  _dateController.text =
                      DateFormat('yyyy-MM-dd').format(picked);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // Submit Button
  Widget _buildSubmitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _submitData,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            backgroundColor: Colors.green[700],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 5,
          ),
          child: Text(
            'Submit Data',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Handle submission of data
  void _submitData() async {
    if (_validateAllInputs()) {
      final soilData = SoilData(
        ph: _phController.text, // Keep it as String
        moisture:
            _moistureController.text.replaceAll('%', ''), // Keep it as String
        temp: _tempController.text.replaceAll('°C', ''), // Keep it as String
        nitrogen: _nitrogenController.text
            .replaceAll('mg/kg', ''), // Keep it as String
        phosphorus: _phosphorusController.text
            .replaceAll('mg/kg', ''), // Keep it as String
        potassium: _potassiumController.text.replaceAll('mg/kg', ''),
        date: _dateController.text,
      );
      final cropService = CropService();
      // Call the insert function to save the data in the database
      await cropService.insertSoilData(soilData);
      log("Data Submit hotoy");
      // Navigate to CropRecommendationPage with the soilData
      clearTextFields();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => CropRecommendationPage(
                  soilData: soilData,
                )),
      );
    }
  }

  // Validate all inputs before submission
  bool _validateAllInputs() {
    final isValidPh = _validatePh(_phController.text).isEmpty;
    final isValidMoisture = _validateMoisture(_moistureController.text).isEmpty;
    final isValidTemp = _validateTemperature(_tempController.text).isEmpty;
    final isValidNitrogen = _validateNitrogen(_nitrogenController.text).isEmpty;
    final isValidPhosphorus =
        _validatePhosphorus(_phosphorusController.text).isEmpty;
    final isValidPotassium =
        _validatePotassium(_potassiumController.text).isEmpty;

    // Show an error message if any validation fails
    if (!isValidPh) {
      _showErrorSnackBar('Invalid pH Level');
      return false;
    }
    if (!isValidMoisture) {
      _showErrorSnackBar('Invalid Moisture');
      return false;
    }
    if (!isValidTemp) {
      _showErrorSnackBar('Invalid Temperature');
      return false;
    }
    if (!isValidNitrogen) {
      _showErrorSnackBar('Invalid Nitrogen Level');
      return false;
    }
    if (!isValidPhosphorus) {
      _showErrorSnackBar('Invalid Phosphorus Level');
      return false;
    }
    if (!isValidPotassium) {
      _showErrorSnackBar('Invalid Potassium Level');
      return false;
    }
    if (_selectedDate == null) {
      _showErrorSnackBar('Please select a date');
      return false;
    }
    return true;
  }

  // Show error messages
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void clearTextFields() {
    _phController.clear();
    _moistureController.clear();
    _tempController.clear();
    _nitrogenController.clear();
    _phosphorusController.clear();
    _potassiumController.clear();
    _dateController
        .clear(); // Use a null-aware operator in case this controller is not initialized
  }
}
