import 'dart:async';
import 'dart:convert'; // For JSON decoding
import 'dart:developer';

import 'package:farma_friend/model/SoilData.dart';
import 'package:farma_friend/pages/compare.dart';
import 'package:farma_friend/services/crop_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class SoilDataInputPageIot extends StatelessWidget {
  const SoilDataInputPageIot({super.key});

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
          child: SoilDataFormIoT(),
        ),
      ),
    );
  }
}

class SoilDataFormIoT extends StatefulWidget {
  const SoilDataFormIoT({super.key});

  @override
  _SoilDataFormState createState() => _SoilDataFormState();
}

class _SoilDataFormState extends State<SoilDataFormIoT> {
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _moistureController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorusController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _deviceIdController =
      TextEditingController(); // Device ID Input

  DateTime? _selectedDate;
  late MqttServerClient _client;
  final String broker = 'broker.hivemq.com';
  final int port = 1883;
  String topic = ''; // MQTT topic (will be set dynamically)
  final String clientId =
      'FlutterAppClient-${DateTime.now().millisecondsSinceEpoch}';
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
  }

  // ✅ Show Popup for Device ID
  Future<void> _askForDeviceId() async {
    String? enteredDeviceId = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text("Enter Device ID", style: GoogleFonts.poppins(fontSize: 18)),
          content: TextField(
            controller: _deviceIdController,
            decoration: InputDecoration(
              hintText: "Enter your device ID",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, null), // Close without saving
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String deviceId = _deviceIdController.text.trim();
                Navigator.pop(context, deviceId.isNotEmpty ? deviceId : null);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );

    if (enteredDeviceId != null) {
      setState(() {
        topic =
            "esp32/soil_data/$enteredDeviceId"; // Merge device ID with topic
      });
      _connectToMQTT(); // Fetch data from MQTT
    }
  }

  // ✅ Connect to MQTT broker and fetch data
  Future<void> _connectToMQTT() async {
    if (topic.isEmpty) {
      _showSnackBar("Please enter a device ID first.", isError: true);
      return;
    }

    setState(() {
      _isFetching = true;
    });

    _client = MqttServerClient(broker, clientId)
      ..port = port
      ..logging(on: false)
      ..keepAlivePeriod = 30
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = _onSubscribed
      ..onSubscribeFail = _onSubscribeFail;

    try {
      log('Connecting to MQTT broker...');
      await _client.connect();
      log('Connected to MQTT broker');
      _client.subscribe(topic, MqttQos.atMostOnce);

      // ✅ Listen for incoming data
      _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>> events) {
        final MqttPublishMessage message =
            events[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);

        if (payload.isNotEmpty) {
          log('Received soil data: $payload');
          try {
            final Map<String, dynamic> soilData = jsonDecode(payload);
            _updateFieldsWithData(soilData); // Update UI
            _showSnackBar("Soil data fetched successfully.");
          } catch (e) {
            log('Error parsing soil data: $e');
            _showSnackBar("Failed to parse data.", isError: true);
          }
        } else {
          _showSnackBar("No data found for this device.", isError: true);
        }
      });

      setState(() {
        _isFetching = false;
      });
    } catch (e) {
      log('Error connecting to MQTT broker: $e');
      _client.disconnect();
      _showSnackBar("Failed to connect to MQTT broker.", isError: true);
      setState(() {
        _isFetching = false;
      });
    }
  }

  void _updateFieldsWithData(Map<String, dynamic> data) {
    setState(() {
      _phController.text = data['ph']?.toString() ?? '';
      _moistureController.text =
          data['moisture'] != null ? '${data['moisture']}%' : '';
      _tempController.text =
          data['temperature'] != null ? '${data['temperature']}°C' : '';
      _nitrogenController.text =
          data['nitrogen'] != null ? '${data['nitrogen']} mg/kg' : '';
      _phosphorusController.text =
          data['phosphorus'] != null ? '${data['phosphorus']} mg/kg' : '';
      _potassiumController.text =
          data['potassium'] != null ? '${data['potassium']} mg/kg' : '';
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    });
  }

  void _onDisconnected() => log('Disconnected from MQTT broker.');
  void _onConnected() => log('Successfully connected to MQTT broker.');
  void _onSubscribed(String topic) => log('Subscribed to topic: $topic');
  void _onSubscribeFail(String topic) => log('Subscription failed: $topic');

  @override
  void dispose() {
    _client.disconnect();
    super.dispose();
  }

  // ✅ Show Snackbars for better user feedback
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('Enter Soil Data'),
        _buildSoilFactorInput('pH Level', _phController),
        _buildSoilFactorInput('Moisture', _moistureController),
        _buildSoilFactorInput('Temperature', _tempController),
        _buildSoilFactorInput('Nitrogen Level', _nitrogenController),
        _buildSoilFactorInput('Phosphorus Level', _phosphorusController),
        _buildSoilFactorInput('Potassium Level', _potassiumController),
        _buildDateField(),
        const SizedBox(height: 20),
        _buildFetchDataButton(),
        const SizedBox(height: 10),
        _buildSubmitButton()
      ],
    );
  }

  Widget _buildTitle<SoilDataFormIoT>(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800])),
      );

  Widget _buildSoilFactorInput<SoilDataFormIoT>(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          filled: true,
          hintText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildFetchDataButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isFetching ? null : _askForDeviceId,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
        ),
        child: _isFetching
            ? const CircularProgressIndicator(color: Colors.white)
            : Text('Fetch Data from Sensor',
                style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
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
    return true;
  }

  // Show error snack bar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Validation functions for each soil factor
  String _validatePh(String value) {
    if (value.isEmpty || double.tryParse(value) == null) {
      return 'Invalid pH value';
    }
    return '';
  }

  String _validateMoisture(String value) {
    if (value.isEmpty || double.tryParse(value.replaceAll('%', '')) == null) {
      return 'Invalid moisture value';
    }
    return '';
  }

  String _validateTemperature(String value) {
    if (value.isEmpty || double.tryParse(value.replaceAll('°C', '')) == null) {
      return 'Invalid temperature value';
    }
    return '';
  }

  String _validateNitrogen(String value) {
    if (value.isEmpty ||
        double.tryParse(value.replaceAll('mg/kg', '')) == null) {
      return 'Invalid nitrogen value';
    }
    return '';
  }

  String _validatePhosphorus(String value) {
    if (value.isEmpty ||
        double.tryParse(value.replaceAll('mg/kg', '')) == null) {
      return 'Invalid phosphorus value';
    }
    return '';
  }

  String _validatePotassium(String value) {
    if (value.isEmpty ||
        double.tryParse(value.replaceAll('mg/kg', '')) == null) {
      return 'Invalid potassium value';
    }
    return '';
  }

  // Clear text fields after submission
  void clearTextFields() {
    _phController.clear();
    _moistureController.clear();
    _tempController.clear();
    _nitrogenController.clear();
    _phosphorusController.clear();
    _potassiumController.clear();
    _dateController.clear();
  }

  // Date picker field
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
}
