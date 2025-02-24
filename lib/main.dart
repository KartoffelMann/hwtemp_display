import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Temps> fetchTemps() async {
  final response = await http.get(
    Uri.parse('http://192.168.1.8:5000/'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Temps.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Temps {
  final double gpuTemp;
  final double cpuTemp;
  final double gpuFan;
  final double cpuFan;

  const Temps({required this.gpuTemp, required this.cpuTemp, required this.gpuFan, required this.cpuFan});

  factory Temps.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'gpuTemp': double gpuTemp, 'cpuTemp': double cpuTemp, 'gpuFan': double gpuFan, 'cpuFan': double cpuFan} => Temps(
        gpuTemp: gpuTemp,
        cpuTemp: cpuTemp,
        gpuFan: gpuFan,
        cpuFan: cpuFan,
      ),
      _ => throw const FormatException('Failed to load temps.'),
    };
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<Temps> futureTemps;

  @override
  void initState() {
    super.initState();
    futureTemps = fetchTemps();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Fetch Data Example')),
        body: Center(
          child: FutureBuilder<Temps>(
            future: futureTemps,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data!.gpuTemp.toString());
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

}