import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  _AddCropScreenState createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers for all parameters
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _seasonController = TextEditingController();
  final TextEditingController _pesticidesController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  final TextEditingController _minTemperatureController =
      TextEditingController();
  final TextEditingController _maxTemperatureController =
      TextEditingController();
  final TextEditingController _minMoistureController = TextEditingController();
  final TextEditingController _maxMoistureController = TextEditingController();
  final TextEditingController _minPHLevelController = TextEditingController();
  final TextEditingController _maxPHLevelController = TextEditingController();
  final TextEditingController _minNitrogenLevelController =
      TextEditingController();
  final TextEditingController _maxNitrogenLevelController =
      TextEditingController();
  final TextEditingController _minPhosphorusLevelController =
      TextEditingController();
  final TextEditingController _maxPhosphorusLevelController =
      TextEditingController();
  final TextEditingController _minPotassiumLevelController =
      TextEditingController();
  final TextEditingController _maxPotassiumLevelController =
      TextEditingController();

  Future<void> _addCropToFirebase() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('crops').add({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'imageUrl': _imageUrlController.text,
          'season': _seasonController.text,
          'pesticides': _pesticidesController.text,
          'id': _idController.text,
          'minTemperature': double.parse(_minTemperatureController.text),
          'maxTemperature': double.parse(_maxTemperatureController.text),
          'minMoisture': double.parse(_minMoistureController.text),
          'maxMoisture': double.parse(_maxMoistureController.text),
          'minPHLevel': double.parse(_minPHLevelController.text),
          'maxPHLevel': double.parse(_maxPHLevelController.text),
          'minNitrogenLevel': double.parse(_minNitrogenLevelController.text),
          'maxNitrogenLevel': double.parse(_maxNitrogenLevelController.text),
          'minPhosphorusLevel':
              double.parse(_minPhosphorusLevelController.text),
          'maxPhosphorusLevel':
              double.parse(_maxPhosphorusLevelController.text),
          'minPotassiumLevel': double.parse(_minPotassiumLevelController.text),
          'maxPotassiumLevel': double.parse(_maxPotassiumLevelController.text),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Crop added successfully!')),
        );
        _formKey.currentState!.reset(); // Reset the form
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add crop: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Crop')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Crop Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a crop name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an image URL' : null,
              ),
              TextFormField(
                controller: _seasonController,
                decoration: const InputDecoration(labelText: 'Season'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the season' : null,
              ),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'ID'),
                validator: (value) => value!.isEmpty ? 'Please enter ID' : null,
              ),
              TextFormField(
                controller: _pesticidesController,
                decoration: const InputDecoration(labelText: 'Pesticides'),
                validator: (value) => value!.isEmpty
                    ? 'Please enter pesticides information'
                    : null,
              ),
              ..._buildNumericFields(),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addCropToFirebase,
                child: const Text('Add Crop'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNumericFields() {
    return [
      _buildNumericField(_minTemperatureController, 'Min Temperature'),
      _buildNumericField(_maxTemperatureController, 'Max Temperature'),
      _buildNumericField(_minMoistureController, 'Min Moisture'),
      _buildNumericField(_maxMoistureController, 'Max Moisture'),
      _buildNumericField(_minPHLevelController, 'Min pH Level'),
      _buildNumericField(_maxPHLevelController, 'Max pH Level'),
      _buildNumericField(_minNitrogenLevelController, 'Min Nitrogen Level'),
      _buildNumericField(_maxNitrogenLevelController, 'Max Nitrogen Level'),
      _buildNumericField(_minPhosphorusLevelController, 'Min Phosphorus Level'),
      _buildNumericField(_maxPhosphorusLevelController, 'Max Phosphorus Level'),
      _buildNumericField(_minPotassiumLevelController, 'Min Potassium Level'),
      _buildNumericField(_maxPotassiumLevelController, 'Max Potassium Level'),
    ];
  }

  Widget _buildNumericField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }
}
