import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Temps>> fetchTemps() async {
  final response = await http.get(
    Uri.parse('http://192.168.1.9:8000/data'),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return (jsonDecode(response.body) as List).map((i) => Temps.fromJson(i)).toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Temps {
  final String identifier;
  final String name;
  final double value;

  const Temps({required this.identifier, required this.name, required this.value});

  factory Temps.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'identifier': String identifier, 'name': String name, 'value': double value} => Temps(
        identifier: identifier,
        name: name,
        value: value,
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
  late Future<List<Temps>> futureTemps;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    futureTemps = fetchTemps();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) => updateTemp());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void updateTemp()
  {
    setState(() {
      futureTemps = fetchTemps();
    });
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
          child: FutureBuilder<List<Temps>>(
            future: futureTemps,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(snapshot.data![9].value.toString());
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