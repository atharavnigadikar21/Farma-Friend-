import 'dart:async';
import 'dart:convert';  // For JSON decoding
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class ESPDiscoveryApp extends StatefulWidget {
  const ESPDiscoveryApp({super.key});

  @override
  _ESPDiscoveryAppState createState() => _ESPDiscoveryAppState();
}

class _ESPDiscoveryAppState extends State<ESPDiscoveryApp> {
  final String broker = 'broker.hivemq.com'; // MQTT Broker
  final int port = 1883; // MQTT Port
  final String topic = 'esp32/soil_data'; // MQTT Topic to subscribe to (Updated)
  final String clientId =
      'FlutterAppClient-${DateTime.now().millisecondsSinceEpoch}'; // Unique Client ID

  late MqttServerClient _client; // MQTT Client
  late StreamController<Map<String, dynamic>> _soilDataStreamController;

  @override
  void initState() {
    super.initState();
    _soilDataStreamController = StreamController<Map<String, dynamic>>();
    _connectToMQTT(); // Connect to the broker on app start
  }

  /// Connect to the MQTT broker and subscribe to the topic
  Future<void> _connectToMQTT() async {
    _client = MqttServerClient(broker, clientId)
      ..port = port
      ..logging(on: true)
      ..keepAlivePeriod = 60 // Extended keep-alive period
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = _onSubscribed
      ..onSubscribeFail = _onSubscribeFail;

    try {
      log('Connecting to MQTT broker...');
      await _client.connect();

      log('Connected to MQTT broker');
      _client.subscribe(topic, MqttQos.atMostOnce);

      // Listen for updates
      _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>> events) {
        final MqttPublishMessage message =
            events[0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(message.payload.message);

        if (payload.isNotEmpty) {
          log('Received soil data: $payload');
          try {
            final Map<String, dynamic> soilData = jsonDecode(payload);
            _soilDataStreamController.add(soilData); // Push soil data to the stream
          } catch (e) {
            log('Error parsing soil data: $e');
          }
        } else {
          log('Received empty payload on topic: $topic');
        }
      });
    } catch (e) {
      log('Error connecting to MQTT broker: $e');
      _client.disconnect();
    }
  }

  /// Handle MQTT disconnection
  void _onDisconnected() {
    log('Disconnected from MQTT broker. Retrying...');
    Future.delayed(
        const Duration(seconds: 5), _connectToMQTT); // Retry after 5 seconds
  }

  /// Handle MQTT connection success
  void _onConnected() {
    log('Successfully connected to MQTT broker.');
  }

  /// Handle topic subscription success
  void _onSubscribed(String topic) {
    log('Successfully subscribed to topic: $topic');
  }

  /// Handle subscription failure
  void _onSubscribeFail(String topic) {
    log('Failed to subscribe to topic: $topic');
  }

  @override
  void dispose() {
    _client.disconnect();
    _soilDataStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ESP32 Soil Data Viewer'),
      ),
      body: Center(
        child: StreamBuilder<Map<String, dynamic>>(
          stream: _soilDataStreamController.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show a loading indicator while waiting
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}'); // Show an error if something goes wrong
            } else if (!snapshot.hasData) {
              return const Text('Waiting for soil data...');
            } else {
              final soilData = snapshot.data!;
              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text('Nitrogen: ${soilData['nitrogen']} mg/L', style: const TextStyle(fontSize: 18)),
                  Text('Phosphorus: ${soilData['phosphorus']} mg/L', style: const TextStyle(fontSize: 18)),
                  Text('Potassium: ${soilData['potassium']} mg/L', style: const TextStyle(fontSize: 18)),
                  Text('pH: ${soilData['ph']}', style: const TextStyle(fontSize: 18)),
                  Text('Temperature: ${soilData['temperature']} °C', style: const TextStyle(fontSize: 18)),
                  Text('Moisture: ${soilData['moisture']} %', style: const TextStyle(fontSize: 18)),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}


 